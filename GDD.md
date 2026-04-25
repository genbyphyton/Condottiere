# Mercenary — Game Design Document

> A 4-player digital area control card strategy game set in the medieval British Isles.

---

## Table of Contents

1. [Game Summary](#game-summary)
2. [Technical Summary](#technical-summary)
3. [Game Process](#game-process)
4. [Factions](#factions)
5. [Cards](#cards)
6. [Hand Management](#hand-management)
7. [Core Game Loop](#core-game-loop)
8. [Map & Locations](#map--locations)
9. [Balance Spreadsheet](#balance-spreadsheet)
10. [Team Roles](#team-roles)

---

## Game Summary

Mercenary is a 4-player digital area control board game with a strong lean into card strategy, set in the medieval British Isles. Players choose one of 4 factions and conquer territory by fighting for it using decks of mercenary cards.

Mercenary is based on the board game **Condottieri** with several revisions and changes to core game rules.

---

## Technical Summary

| Property | Detail |
|----------|--------|
| Game Engine | Godot 4 |
| Player Count | 4 |
| Genre | Area Control / Card Strategy |
| Estimated Play Time | 30–60 minutes |
| Version Control | Git / GitHub |

---

## Game Process

### Game Objective & Win Conditions

Players compete to conquer regions of the British Isles using card-based battles. A player wins by achieving either of the following:

- First to control **5 total regions**
- First to control **3 adjacent regions**

Regions are adjacent if they share a common border on the map.

---

### Game Objects

| Object | Description |
|--------|-------------|
| Conquer Token | Used to choose which of the 16 regions the next battle will be fought over |
| Faction Token | Placed on each conquered region to mark ownership |
| Favor of the Pontiff | Any region with this token may not be attacked |

---

### Kick Off Phase

1. Each player chooses one of 4 factions
2. One player is randomly chosen to go first
3. Each player receives 10 random cards from the deck
4. The first player places the Conquer Token on any uncontrolled region to begin the first battle

---

### Battle Phase

The player holding the Conquer Token takes the first turn. Players then take turns clockwise.

On each turn a player must either:

- **Play** — place one card face-up into their battle line
- **Pass** — announce pass and exclude themselves from further card play this battle

> A player's total strength is the sum of all strength values in their battle line, modified by any active special cards.
> A player who passes may still win the battle if their line is strongest at resolution.

Battle ends when **all players have passed** or a **Surrender card** is played.

---

### Comparison Phase

All players reveal their total battle line strength. The player with the highest total:

- Conquers the region
- Places their Faction Token on it
- Receives the Conquer Token

---

### Strength

Strength is the core numerical value that determines the outcome of every battle. Each Mercenary card carries a printed strength value between 1 and 10. A player's total strength at any point in a battle is the sum of all strength values across their entire battle line, modified by any active special cards.

---

## Factions

Each faction has a passive ability that can be used every Battle Phase.

| Faction | Ability Name | Description | When |
|---------|-------------|-------------|------|
| Scotland | Highland Morale | +1 to each Mercenary's strength | Comparison Phase |
| Ireland | Spy Work | Swap one card from hand with an opponent's card on the battlefield | Immediate |
| Wales | Storm Control | Discard all season cards in play, costs one card from battle line | Comparison Phase |
| England | Bluff | All played cards are placed face down until Comparison Phase | Immediate |

---

## Cards

### Quick Reference

| Card | Description |
|------|-------------|
| Mercenary | Primary strength source |
| Winter | Reduces all Mercenary cards to strength 1 |
| Spring | Adds +3 strength to your highest Mercenary cards |
| Autumn | Scarecrow and Surrender cannot be played this battle |
| Bishop | Discards all highest-strength Mercenaries on the battlefield and grants Favor of the Pontiff |
| Courtesan | Most Courtesans in your line wins the Conquer Token regardless of battle outcome |
| Drummer | Doubles the printed strength of all Mercenaries in your line |
| Heroine | Flat 10 strength, immune to all modifiers |
| Scarecrow | Retrieve one of your Mercenaries from the battlefield back to your hand |
| Surrender | Ends the battle immediately, current leader takes the region |

---

### Main Cards

**Mercenary**
Mercenary cards are the most common strength-providing cards. There are 10 of the 1-strength Mercenary cards and 8 each of the 2-, 3-, 4-, 5-, 6-, and 10-strength Mercenary cards in the deck.

---

### Season Cards

**Winter**
When a Winter card is in play when a battle is concluded, all Mercenary cards are considered to have a printed strength of 1.
> When a Winter card is played, immediately discard all Autumn cards in play.

**Spring**
When a Spring card is in play when a battle is concluded, each player adds 3 strength to each of their Mercenary cards that is among the highest-strength Mercenaries in play.
> When a Spring card is played, immediately discard all Winter cards in play.

**Autumn**
When an Autumn card is in play, none of the players can use Scarecrow or Surrender cards.
> When an Autumn card is played, immediately discard all Spring cards in play.

---

### Special Cards

**Bishop**
When a Bishop card is played, all of the highest-strength Mercenary card(s) in play are discarded across all battle lines. The player who played the Bishop receives the Favor of the Pontiff token and must immediately decide whether to place it on a region that does not contain a control marker or leave it off the board. The Conquer Token may not be placed on any region that has the Favor of the Pontiff.

**Courtesan**
If, during the Compare Strength step, a player's battle line contains the most Courtesan cards, that player receives the Conquer Token instead of the player who actually won the battle. The battle winner still places their Faction Token on the region, but the player with the most Courtesans chooses where the next battle is fought and takes the first turn.
> If two players tie for most Courtesans, the battle winner keeps the Conquer Token.

**Drummer**
When a battle is concluded, all Mercenary cards in the same battle line as a Drummer have their printed strength doubled. Multiple Drummers have no additional effect.

**Heroine**
Has a strength of 10 but is not considered a Mercenary card and is therefore not affected by Winter, Spring, Autumn, Drummer, or Scarecrow.

**Scarecrow**
Allows a player to retrieve one of their own Mercenary cards from their battle line back into their hand. A player may choose not to retrieve a card. Cannot retrieve special cards.

**Surrender**
When played, immediately ends the battle. The region is captured by the player with the strongest battle line at the moment Surrender is played.

---

### Hierarchy of Abilities

When card effects overlap, resolve in the following order — highest priority first.

| Priority | Card | Description | Timing |
|----------|------|-------------|--------|
| 1 | Surrender | Ends battle immediately | Immediate |
| 2 | Bishop | Discards highest-strength Mercenaries | Immediate |
| 3 | Scarecrow | Retrieves a Mercenary from battle line | Immediate |
| 4 | Drummer | Doubles printed Mercenary strength | Immediate |
| 5 | Autumn | Disables Scarecrow and Surrender | Immediate |
| 6 | Winter / Spring | Modifies Mercenary strength at resolution | Comparison Phase |
| 7 | Faction Abilities | Varies by faction | Immediate / Comparison |
| 8 | Courtesan | Redirects Conquer Token | After winner is determined |

---

### Card Distribution

| Card | Strength | Count |
|------|----------|-------|
| Mercenary (1) | 1 | 10 |
| Mercenary (2) | 2 | 8 |
| Mercenary (3) | 3 | 8 |
| Mercenary (4) | 4 | 8 |
| Mercenary (5) | 5 | 8 |
| Mercenary (6) | 6 | 8 |
| Mercenary (10) | 10 | 8 |
| Winter | — | 2 |
| Spring | — | 2 |
| Autumn | — | 2 |
| Bishop | — | 3 |
| Courtesan | 1 | 12 |
| Drummer | — | 6 |
| Heroine | 10 | 3 |
| Scarecrow | — | 16 |
| Surrender | — | 3 |
| **Total** | | **110** |

---

## Hand Management

| Rule | Value |
|------|-------|
| Starting hand size | 10 cards per player |
| Bonus cards per controlled region | +1 card per region |

### Hand Refill

- Players do not draw cards after every battle — hands are refilled at the end of a round
- A round ends when all but one player has run out of cards
- The remaining player may keep up to 2 cards and discards the rest
- All discarded and played cards are shuffled back into the deck
- Each player receives a fresh hand of 10 cards plus 1 bonus card per region they control
- If a player runs out of cards mid-round they must pass every turn until the next refill

---

## Core Game Loop
### 1. Setup
- Each player chooses a faction and receives 10 cards
- One player is randomly chosen to hold the Conquer Token

### 2. Choose Battlefield
- The Conquer Token holder places it on any uncontrolled region

### 3. Battle
- Starting with the Conquer Token holder, players take turns clockwise
- Each turn: play one card into battle line or pass
- Once a player passes they cannot play further cards this battle
- Battle ends when all players have passed or Surrender is played

### 4. Resolution
- All battle lines are evaluated
- Special card effects resolve in hierarchy order
- Highest total strength wins the region and takes the Conquer Token

### 5. Win Condition Check
- Does the winner control 5 total regions? → Game over
- Does the winner control 3 adjacent regions? → Game over
- Neither → continue

### 6. Next Battle
- Conquer Token holder picks the next region
- Return to step 3

### 7. Hand Refill (end of round only)
- When all but one player is out of cards the round ends
- Deck is reshuffled
- Each player receives 10 cards plus 1 per region controlled

### 8. Repeat

---

## Map & Locations

![Map of the British Isles with 16 numbered regions]

### Location Table

| Region | Territory | Adjacent Territories |
|--------|-----------|---------------------|
| 1 | Highlands | Grampian, Strathclyde |
| 2 | Grampian | Highlands, Strathclyde, Dunwall |
| 3 | Strathclyde | Grampian, Highlands, Northumbria |
| 4 | Northumbria | Strathclyde, Yorkshire, Mercia |
| 5 | Yorkshire | Northumbria, Mercia, East Anglia |
| 6 | Mercia | Northumbria, Yorkshire, Wales, East Anglia |
| 7 | Wales | Mercia, East Anglia, Somerset, Wessex |
| 8 | East Anglia | Yorkshire, Mercia, Wales, Wessex, Essex |
| 9 | Somerset | Wales, Wessex |
| 10 | Wessex | Wales, East Anglia, Somerset, Essex, Cornwall, Kent |
| 11 | Essex | East Anglia, Wessex, Kent |
| 12 | Cornwall | Wessex, Kent |
| 13 | Kent | Wessex, Essex, Cornwall |
| 14 | Dunwall | Tirconnell, Velen, Grampian |
| 15 | Tirconnell | Dunwall, Velen |
| 16 | Velen | Dunwall, Tirconnell |

> **Note:** Dunwall and Velen are fictional regions. Tirconnell, Dunwall, and Velen form an isolated cluster — the only mainland connection is through Dunwall → Grampian.

---

## Balance Spreadsheet

### Deck Baseline

| Card | Strength | Count | Total Strength | % of Deck |
|------|----------|-------|----------------|-----------|
| Mercenary (1) | 1 | 10 | 10 | 9.1% |
| Mercenary (2) | 2 | 8 | 16 | 7.3% |
| Mercenary (3) | 3 | 8 | 24 | 7.3% |
| Mercenary (4) | 4 | 8 | 32 | 7.3% |
| Mercenary (5) | 5 | 8 | 40 | 7.3% |
| Mercenary (6) | 6 | 8 | 48 | 7.3% |
| Mercenary (10) | 10 | 8 | 80 | 7.3% |
| Courtesan | 1 | 12 | 12 | 10.9% |
| Heroine | 10 | 3 | 30 | 2.7% |
| Winter | 0 | 2 | 0 | 1.8% |
| Spring | 0 | 2 | 0 | 1.8% |
| Autumn | 0 | 2 | 0 | 1.8% |
| Bishop | 0 | 3 | 0 | 2.7% |
| Drummer | 0 | 6 | 0 | 5.5% |
| Scarecrow | 0 | 16 | 0 | 14.5% |
| Surrender | 0 | 3 | 0 | 2.7% |
| **Total** | | **110** | **292** | **100%** |

**Key numbers:**
- Average strength per card: **2.65**
- Expected starting hand strength: **26.5**
- Expected Mercenaries in starting hand: **5–6**
- Expected non-zero strength cards in hand: **6–7**

---

### Card Effect Impact

| Scenario | Hand Strength | vs Baseline | % Change | Notes |
|----------|--------------|-------------|----------|-------|
| Baseline | 26.5 | — | — | Starting reference |
| Winter active | 8.0 | -18.5 | -70% | All Mercenaries count as 1 |
| Spring active | 31.5 | +5.0 | +19% | +3 to highest Mercenary tier |
| Autumn active | 26.5 | 0 | 0% | No strength change, restricts cards |
| Drummer active | 45.8 | +19.3 | +73% | Mercenaries doubled |
| Drummer + Winter | 10.6 | -15.9 | -60% | Mercenaries = 1, Drummer doubles to 2 |
| Drummer + Spring | 53.8 | +27.3 | +103% | Double first, then +3 to highest |
| Best possible hand | 100.0 | +73.5 | +277% | All 10-strength Mercenaries |
| Worst possible hand | 6.0 | -20.5 | -77% | All 1-strength Mercenaries |

---

### Faction Comparison

| Faction | Baseline | + Drummer | + Winter | + Spring | + Autumn | Average | vs Baseline |
|---------|----------|-----------|----------|----------|----------|---------|-------------|
| No Faction | 26.5 | 45.8 | 8.0 | 31.5 | 26.5 | 27.7 | — |
| Scotland (+1 per Mercenary) | 31.8 | 51.1 | 13.3 | 36.8 | 31.8 | 32.96 | +19% |
| Ireland (avg +3 swap) | 29.5 | 48.8 | 11.0 | 34.5 | 29.5 | 30.7 | +11% |
| Wales (cancel season) | 26.5 | 45.8 | 26.5* | 26.5* | 26.5* | 30.4 | +10% |
| England (bluff est. +2) | 28.5 | 47.8 | 10.0 | 33.5 | 28.5 | 29.7 | +8% |

*Wales cancels season effects entirely, reverting to baseline

**Balance notes:**
- Scotland is the strongest faction at +19% above baseline — monitor in playtesting
- Wales is weakest in neutral games but strongest when season cards are active
- Ireland and England sit in a healthy middle range
- Drummer + Spring combo at +103% is the highest single swing in the game

---

### Win Condition Analysis

| Chain | Regions | Battles Required | Difficulty | Blockable By |
|-------|---------|-----------------|------------|--------------|
| North chain | Highlands→Grampian→Strathclyde | 3 | Low | Grampian |
| South chain | East Anglia→Wessex→Kent | 3 | Low | Wessex |
| Ireland cluster | Dunwall→Tirconnell→Velen | 3 | Medium | Dunwall |
| Mid-England | Northumbria→Mercia→Wales | 3 | High | Mercia |

| Metric | Value |
|--------|-------|
| Minimum battles to win via adjacent | 3 |
| Minimum battles to win via total regions | 5 |
| Most connected region | Wessex (6 adjacencies) |
| Least connected regions | Highlands, Somerset, Tirconnell, Velen (2 each) |
| Most important blocking region | Grampian (sits on 2 northern chains) |

---

## Team Roles

| Role | Name | Responsibilities |
|------|------|-----------------|
| Game Designer / Team Lead | Omar Aslan | Game rules, card balance, faction design, GDD maintenance |
| Lead Programmer / Game Designer | Igor Chsheglov | Core game loop, card systems, technical architecture |
| Programmer | Togzhan Tleugali | AI logic, map interaction, UI systems |
| Narrative Writer / Artist | Konstantin Maslov | In-game narrative, card descriptions, card art |
| UI / Artist | Ayana Kassenova | User interface, card art support |
