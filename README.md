[Game Design Document](/GDD%20-%20Condottieri%20-3.pdf)

# Mercenary

> A 2–4 player digital area control card strategy game set in the medieval British Isles.

---

## Overview

Mercenary is a digital adaptation of the board game **Condottieri**, rebuilt with revised core rules and set across 16 regions of the British Isles. Players choose a faction, deploy mercenary armies through card battles, and fight to conquer territory.

---

## Built With

- **Engine:** Godot 4
- **Version Control:** Git / GitHub
- **Genre:** Area Control / Card Strategy
- **Players:** 2–4
- **Play Time:** 30–60 minutes

---

## How to Win

- Control **5 total regions**, or
- Control **3 adjacent regions**

---

## Factions

| Faction | Ability | Description |
|---------|---------|-------------|
| Scotland | Highland Morale | +2 to all Mercenary cards during Counting Phase |
| Ireland | Spy Work | Exchange any card from opponent's battlefield with one of yours |
| Wales | Storm Control | Discard all active weather cards from the battlefield |
| England | Bluff | All played cards are placed face down until Counting Phase |

---

## Card Types

| Card | Count | Effect |
|------|-------|--------|
| Mercenary (1) | 10 | Strength 1 |
| Mercenary (2–6) | 8 each | Strength 2–6 |
| Mercenary (10) | 8 | Strength 10 |
| Winter | 2 | All Mercenaries count as strength 1 |
| Spring | 2 | +3 to highest strength Mercenaries |
| Autumn | 2 | Scarecrow and Surrender cards cannot be used |
| Bishop | 3 | Discards all highest-strength Mercenaries; grants Favor of the Pope |
| Courtesan | 12 | Most Courtesans = receive Conquer Token instead of battle winner |
| Drummer | 6 | Doubles printed strength of all Mercenaries in your battle line |
| Heroine | 3 | Strength 10, unaffected by any modifiers |
| Scarecrow | 16 | Retrieve one of your Mercenaries from the battlefield to hand |
| Surrender | 3 | Ends battle immediately; current leader wins |

---

## Ability Resolution Order

1. Surrender
2. Bishop
3. Scarecrow
4. Drummer
5. Winter / Spring / Autumn
6. Faction Abilities
7. Courtesan

---


<img width="391" height="460" alt="Untitled-1" src="https://github.com/user-attachments/assets/0c0a3ecf-ae2b-43fa-b8d2-89bc4f06a22b" />


## Map — 16 Regions

| # | Territory | Adjacent Regions |
|---|-----------|-----------------|
| 1 | Highland | Lowland, Strathclyde |
| 2 | Lowland | Highland, Strathclyde, Dunwall |
| 3 | Strathclyde | Lowland, Highland, Northumbria |
| 4 | Northumbria | Strathclyde, Ulster, Mercia, East Anglia |
| 5 | Connacht | Northumbria, Mercia, Kent |
| 6 | Ulster | Northumbria, East Anglia, Wales, Wessex |
| 7 | Leinster | Mercia, Wessex |
| 8 | Munster | East Anglia, Wessex |
| 9 | Mercia | Leinster, East Anglia, Wessex |
| 10 | East Anglia | Leinster, Munster, Mercia, Wales, Wessex, Kent |
| 11 | Wales | Munster, East Anglia, Kent |
| 12 | Wessex | Mercia, East Anglia, Kent |
| 13 | Kent | East Anglia, Wales, Wessex |
| 14 | Dunwall *(fictional)* | Cornwall, Velen, Lowland |
| 15 | Cornwall | Dunwall, Velen |
| 16 | Velen *(fictional)* | Dunwall, Cornwall |

---

## Team

| Role | Name |
|------|------|
| Game Designer / Team Lead | Omar Aslan |
| Lead Programmer / Game Designer | Igor |
| Programmer | Togzhan |
| Narrative Writer / Artist | Konstantine Maslov |
| UI / Artist | Ayana Kasenova |

---

## License

This project is developed for educational purposes.
