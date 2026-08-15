# ayuStream Digital Signage: Advertising Packages & Scheduling Architecture

## Overview
This document defines the end-to-end architecture, package models, and time-throttling engine for the **ayuStream** Digital Signage Advertising Network, covering:
1. **Advertiser App (`ayuStream`)**
2. **Venue Admin Dashboard (`nightmusictoughtdasboard`)**
3. **TV Display Hardware Application (`night_track_tv`)**

---

## 1. End-to-End System Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. VENUE ADMIN CONFIGURATION (nightmusictoughtdasboard)                     │
│    • Defines Ad Broadcast Hours (e.g., Night Prime: 18:00 – 23:30, Wed–Sun) │
│    • Sets custom Package Rates (Weekly, Monthly, Seasonal)                  │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Saved in Firestore: organizations/{orgId}
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. ADVERTISER CREATION & PACKAGE SELECTION (ayuStream)                      │
│    • Selects one or multiple venues                                         │
│    • Chooses Package: [1 Week Starter] | [1 Month Pro] | [3 Months Master]  │
│    • Automatic alignment with venue active hours and discount pricing       │
│    • Uploads media & submits (status: pending_approval)                     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. VENUE ADMIN APPROVAL (nightmusictoughtdasboard)                          │
│    • Reviews creative preview and package term (e.g., 30 Days @ 18:00–23:30)│
│    • Approves request (status: approved / active)                           │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. AUTONOMOUS TV SCHEDULER & THROTTLING (night_track_tv)                    │
│    • Runs 4-Tier Clock Engine:                                              │
│      1. Date Check: startDate <= Today <= endDate                          │
│      2. Day of Week: daysOfWeek contains Today.weekday                     │
│      3. Active Hours: startTime <= CurrentTime <= endTime                  │
│      4. Frequency Lockout: (Now - lastDisplayedAt) >= frequencyMinutes      │
│    • Plays fullscreen 15s SignageAdOverlay at exact intervals               │
│    • Resumes normal venue content (menu, music, sports) between ad slots    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Standardized Advertising Packages

| Package Tier | Duration | Frequency | Discount | Target Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Weekly Starter** | 7 Days | Every 15 min | Standard Rate | Weekend events, new product launches, flash promotions |
| **Monthly Pro** | 30 Days | Every 15 min | **20% OFF** | Continuous brand presence, local businesses, gyms, restaurants |
| **Quarterly Season** | 90 Days | Every 15 min | **35% OFF** | Corporate sponsors, beverages, telecoms, financial brands |
| **Event Flash Takeover** | 1 Day | Every 5 min | Premium Rate | Concerts, World Cup finals, Holiday Eve celebrations |

---

## 3. 4-Tier TV Display Execution Rules (`night_track_tv`)

Before any ad triggers on screen, the TV engine validates:
1. **Date Boundary**: Is `now` between `startDate` (00:00:00) and `endDate` (23:59:59)?
2. **Day of Week**: Is `now.weekday` (1=Mon ... 7=Sun) included in `daysOfWeek`?
3. **Active Hours Window**: Is the current clock time between `startTime` (e.g., `"18:00"`) and `endTime` (e.g., `"23:30"`)?
4. **Frequency Lockout**: Has at least `frequencyMinutes` (e.g. 15 min) elapsed since `lastDisplayedAt`?

If **all 4 pass**, the ad plays for `displayDurationSeconds` (e.g. 15s), logs the impression, and locks out the campaign until the next interval.

---

## 4. Firestore Document Schema (`ad_campaigns`)

```json
{
  "id": "ad_camp_1786732718",
  "campaignGroupId": "grp_1786735696539_2",
  "advertiserId": "user_uid_123",
  "organizationId": "rest19",
  "organizationName": "Rest Fine Dining",
  "title": "Summer Happy Hour 2-for-1",
  "caption": "Enjoy 2-for-1 cocktails every Wednesday to Sunday",
  "mediaUrl": "https://res.cloudinary.com/.../ad.png",
  "mediaType": "image",
  "packageTier": "monthly",
  "startDate": "2026-08-15T00:00:00.000Z",
  "endDate": "2026-09-14T23:59:59.000Z",
  "startTime": "18:00",
  "endTime": "23:30",
  "daysOfWeek": [3, 4, 5, 6, 7],
  "frequencyMinutes": 15,
  "displayDurationSeconds": 15,
  "budget": 3900.0,
  "status": "active",
  "impressionCount": 42,
  "lastDisplayedAt": "2026-08-15T19:15:00.000Z",
  "createdAt": "2026-08-15T12:00:00.000Z"
}
```
