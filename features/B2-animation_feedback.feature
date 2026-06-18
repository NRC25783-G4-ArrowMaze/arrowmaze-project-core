# animation_feedback.feature

Feature: Engine Action Animation and Visual Feedback
  As a player on a web/Android client
  I want the movement, collision, exit and destruction of arrows to be animated
  So that I can perceive what the game engine decided each tick as a fluid, readable motion

# CONSUMED DOMAIN CONCEPTS (READ-ONLY — see A3 and B1)
#
# This is an INFRASTRUCTURE / PRESENTATION feature. It consumes domain
# outcomes; it never produces, alters, or reorders them.
#
# Tick           : Atomic movement unit resolved by the domain (A3).
# Outcome        : The already-decided result of a tick for an Arrow:
#                    - advanced  : head claimed a new Cell, tail released one
#                    - blocked   : "ArrowBlocked" — rollback, no Cell changed
#                    - exited    : head reached a sink (isExit) and the Arrow
#                                  shrinks / is destroyed
# Occupation     : Ordered sequence of Cells an Arrow occupies (B1), before
#                  and after a tick (pre-state / post-state).
# Port direction : Port index -> screen delta mapping owned by B1. B2 reuses
#                  it as the glide vector; it does NOT redefine it.
# cellSize       : Viewport-derived unit from B1, reused for distances.
#
# CORE INVARIANT
#
# The domain resolves the tick FIRST and atomically. The animation only
# replays an already-final transition. Disabling, skipping, or fast-forwarding
# any animation leaves the domain state and the final rendered state identical.
# No animation event ever flows back into the domain.
#
# DESIGN DECISIONS (SDD session 2026-06-18)
#   D1 Control model      : BLOCKING. Player input and the next tick are locked
#                           while the current tick's animation window plays.
#   D2 Collision feedback : RECOIL + spring back only. No flash, no in-place
#                           shake, no reaction on the blocking arrow.
#   D3 Exit / destruction : FADE AT THE EDGE, HEAD-FIRST. Each segment dissolves
#                           as it crosses the board edge, starting with the
#                           first segment to exit (the head). No tail-first
#                           shrink.
#   D4 Multi-arrow timing : STAGGERED. Arrows moving on the same tick start with
#                           a small per-arrow offset for readability, but all
#                           finish inside the same tick window.

  Background: A rendered board driven by resolved engine ticks
    Given a Board has been statically rendered per B1 (dots, bodies, heads)
    And the renderer knows each Arrow's occupation before and after a tick
    And the domain exposes, per Arrow per tick, an outcome in {advanced, blocked, exited}
    And the port-to-screen-direction mapping from B1 is available
    And animations run on wall-clock time while domain ticks remain discrete

  Rule: Animation is a read-only projection of domain outcomes

    Scenario: The domain decides, the animation replays
      Given the domain has resolved a tick with outcome "advanced" for Arrow A
      When the animation layer receives that outcome
      Then it animates A from its pre-state occupation to its post-state occupation
      And it never asks the domain to re-evaluate the tick
      And it never writes back any position, port, or occupation value

    Scenario: Disabling animations does not change game state
      Given the same sequence of domain ticks is applied twice
      And in the first run animations are enabled
      And in the second run animations are disabled
      When both runs finish
      Then the final domain state is identical in both runs
      And the final rendered occupation is identical in both runs

  Rule: Control model is blocking during a tick's animation window (D1)

    Scenario: Input is locked until the animation window closes
      Given a tick is currently animating
      When the player attempts an action
      Then the action is rejected or buffered, not applied to the domain mid-window
      And control is restored only after the animation window closes

    Scenario: The next tick waits for the current window to finish
      Given tick N is animating
      And the domain has tick N+1 ready
      When tick N's animation window is still open
      Then tick N+1's animation does not begin
      And tick N+1 starts only once tick N's window has closed

    Scenario: A skipped animation closes the window immediately
      Given a tick is animating
      When the player requests skip/fast-forward
      Then every arrow in the tick snaps to its post-state occupation
      And the window closes at once
      And the same outcomes the domain decided remain the ones shown

  Rule: Movement animation interpolates between pre-tick and post-tick occupation

    Scenario: Single-cell arrow glides one port toward its exit direction
      Given Arrow A occupies Cell C1 with head exitPort P before the tick
      And the outcome is "advanced" with post-state occupation Cell C2
      When the movement animation plays
      Then A's head translates from C1 center to C2 center
      And the translation direction equals B1's screen delta for port P
      And at animation end A is drawn exactly at its post-state occupation

    Scenario: Multi-segment arrow animates all its own segments simultaneously (head-push)
      Given Arrow A occupies [C1(head), C2(body), C3(tail)] before the tick
      And the outcome is "advanced" with post-state [C2, C3, C4]
      When the movement animation plays
      Then every segment of A starts and ends its glide within the same tick window
      And the head, body and tail translate in parallel, not in sequence
      And the body inherits the head's previous center as its target
      And the visual occupation order is preserved throughout the glide

  Rule: Multiple arrows on the same tick animate staggered (D4)

    Scenario: Arrows start with an ascending offset but share one window
      Given Arrows A and B both have "advanced" outcomes on the same tick
      And a per-arrow stagger offset S smaller than the glide duration
      When the tick animates
      Then A begins its glide at the window start
      And B begins its glide S later
      And both glides have completed before the window closes
      And the domain still treats both outcomes as belonging to the same tick

    Scenario: Stagger never reorders ticks or outcomes
      Given staggered arrows with different start offsets
      When the tick window closes
      Then the rendered state equals the domain post-state for every arrow
      And the order of subsequent ticks is unaffected by the stagger offsets

  Rule: Collision feedback is a recoil and spring-back (D2)

    Scenario: Blocked arrow recoils toward the port and returns to its anchor
      Given Arrow A is anchored at Cell C1 with head exitPort P
      And the outcome is "blocked"
      When the collision animation plays
      Then A's head nudges a fraction of cellSize toward port P and springs back
      And A ends the animation at its original pre-state occupation
      And the blocked target Cell never shows A's head entering it

    Scenario: The blocking arrow does not react to the collision
      Given Arrow A is blocked by an occupying Arrow B at the target Cell
      When the collision animation of A plays
      Then only A performs the recoil and spring-back
      And Arrow B's drawn occupation and appearance are unchanged
      And no flash or in-place shake is emitted

  Rule: Exit and destruction fade at the board edge, head-first (D3)

    Scenario: Single-cell arrow fades out as it crosses the edge
      Given Arrow A occupies a single Cell with head exitPort P reporting isExit
      And the outcome is "exited"
      When the exit animation plays
      Then A's head glides outward through port P toward the board edge
      And A fades out as it crosses the edge
      And A's visual is removed once the fade completes

    Scenario: Multi-segment arrow dissolves head-first across successive exits
      Given Arrow A occupies [C1(head)..C5(tail)] and the head reaches a sink
      When the successive exit ticks are animated
      Then on each tick the leading segment glides to the edge and fades as it crosses
      And segments dissolve in head-first order, the first to exit fading first
      And no segment fades before the segment ahead of it has crossed
      And once the last segment has faded, A is gone

    Scenario: The fade reads only its own captured data, never the freed Cells
      Given the domain has already set the freed Cells' arrowSegment to null
      When the fade effect is still playing on screen
      Then the effect animates from its own captured segment positions
      And it never queries or revives the released domain Cells

  Rule: Determinism — animation timing never affects tick semantics

    Scenario: Timing parameters do not change the simulation
      Given a fixed sequence of domain ticks
      When the same sequence is animated with different durations and offsets
      Then the domain outcomes and their order are identical across runs
      And only the on-screen pacing differs