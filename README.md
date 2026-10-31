# My Week 📅

**My Week** is a Flutter timetable and course management application designed to organize weekly class schedules, automatically sort courses chronologically, calculate daily and weekly total class hours, and alert users to schedule clashes in real-time.

---

## 📌 Project Overview
- **App Name**: My Week
- **Project Chosen**: Project #6 - My Week (Mobile Programming - Week 2, Session 4 Mini Project)
- **Built On**: Labs 7 (Clash Detection), 1 (Time Handling), and 9 (Sorting & Ranking)
- **Extended In**: Week 3, Session 6 - *Firebase: your app in the cloud* (Firebase Auth + Cloud Firestore)

---

## ✨ Features
1. **At Least Two Screens**:
   - **Week Screen (`WeekScreen`)**: Primary dashboard displaying weekly summary, day selector chips (Mon–Fri), daily class statistics, free time gaps, and course list.
   - **Add/Edit Course Screen (`CourseFormScreen`)**: Dedicated screen for adding new courses or editing existing ones with time validation.
2. **Chronological Course Order**: Courses for each day are automatically sorted by start time (`08:00`, `09:00`, `11:00`, etc.).
3. **Real-time Clash Detection**:
   - Detects overlapping courses on the same day.
   - Highlights clashing courses in red and explicitly displays the names of clashing courses (e.g., *Clashes with Physics*).
   - Dynamic update: editing a time to remove overlap automatically clears the red warning banner on both affected courses.
4. **Time & Hour Calculations**:
   - Converts `HH:MM` formatted strings to total minutes for comparisons and back into formatted hours (e.g., `3h 30m`).
   - Displays daily total class hours and weekly total hours in a header card.
5. **Strict Input Validation**:
   - Refuses invalid time formats like `8h`, `25:00`, `10:75`.
   - Prevents end times that occur at or before the start time.
   - Refuses empty course names with clear feedback messages via floating `SnackBar`s.
6. **Fixing Mistakes (Edit & Undo)**:
   - Tap any course card to edit.
   - Delete confirmation dialog prevents accidental deletions.
   - Deleted courses can be restored instantly using the `Undo` button on the `SnackBar`.
7. **No Blank Screens**:
   - When a selected day has no classes, a clear empty state message is shown (e.g., *No classes on Wednesday*).
8. **Free Time Gap Indicator**:
   - Automatically detects and displays free time slots between consecutive classes on the selected day (e.g., `🌱 Free: 10:00–10:30 (30m)`).

---

## ☁️ Cloud Storage (Week 3 · Session 6 - Firebase)

The app now stores its data in the cloud instead of only in memory.

### Accounts
- **Firebase Authentication** with **Email/Password** sign-in.
- `AuthGate` listens to `authStateChanges()`: a signed-in user sees the Week screen, a signed-out user sees the login screen. There is no way to reach the Week screen without an account.
- A brand-new account automatically gets the sample courses written to Firestore, so the app is never blank.

### Data
- Collection path: `users/{uid}/courses/{courseId}` - every document is scoped to the signed-in user.
- Fields stored: `name`, `day`, `startTime`, `endTime` (text `HH:MM`), plus `createdAt` (server timestamp).
- The per-day hours, weekly hours and clash count are **computed in the app and never saved** - only the four real fields are stored.
- The week list is a `StreamBuilder` on `collection.snapshots()`, so edits appear live on every device signed into the same account.

### Rules (proving the data is private)
`firestore.rules` is committed in this repo:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

A second account has a different `uid`, so it can never read or write the first account's documents.

### Loading, error and empty states
- **Loading**: "Loading your week..." while the Firestore snapshot is being fetched.
- **Error**: "Could not load your courses" with the real Firestore error if the read is refused.
- **Empty**: "No classes on \<day\>" when the selected day has nothing scheduled.
- **Setup**: a "Firebase isn't set up yet" screen if the web config has not been pasted in.

### One-time Firebase setup
1. Create a project at <https://console.firebase.google.com>.
2. **Build → Authentication → Get started → Email/Password → Enable**.
3. **Build → Firestore Database → Create database** (production mode), then paste `firestore.rules` into the **Rules** tab and **Publish**.
4. **Project settings → Your apps → Web (`</>`)** → register `my-week-web` and copy the `firebaseConfig`.
5. Paste those values into `lib/firebase_options.dart` (replace the six `PASTE_...` values).
6. For Android, download `google-services.json` into `android/app/`.

---

## 📱 Screenshots

| Week Dashboard | Clash Alert | Add / Edit Course | Empty Day State |
| :---: | :---: | :---: | :---: |
| *(Screenshot 1)* | *(Screenshot 2)* | *(Screenshot 3)* | *(Screenshot 4)* |

*(Note: Add screenshots of your app running on device/emulator to your repo before submitting)*

---

## 🤔 Think Questions & Answers

### 1. Write your clash condition in plain words. Why `<` and not `<=`?
**Answer**:
> Two courses on the same day clash if each course starts before the other course ends. In code:
> `c1.startMinutes < c2.endMinutes && c2.startMinutes < c1.endMinutes`
>
> We use `<` (strictly less than) rather than `<=` because a class ending at 11:00 (`c1.endMinutes = 660`) and another starting at 11:00 (`c2.startMinutes = 660`) do **not** overlap in time—one ends exactly as the second begins.
>
> Evaluating `660 < 660` returns `false`, correctly allowing back-to-back classes. Using `<=` would evaluate `660 <= 660` as `true` and incorrectly flag non-overlapping consecutive classes as a clash.

### 2. Why is it easier to store times as minutes than as text like `08:30`?
**Answer**:
> Storing or converting times into total minutes from midnight (e.g., `08:30` -> `8 * 60 + 30 = 510` minutes) reduces complex time calculations to basic integer arithmetic:
> - **Comparison & Sorting**: Checking if time A is earlier than time B is simply `510 < 600`.
> - **Duration Calculation**: Class length is simply `endMinutes - startMinutes` (e.g., `600 - 510 = 90` minutes = `1h 30m`).
> - **Clash Detection**: Overlap logic requires basic integer inequality checks.
>
> String operations on `"08:30"` (e.g. string splitting, regex parsing, or alphabetical string comparison) are much slower, error-prone, and require repetitive parsing code across multiple functions.

---

## ✅ Session 6 - "Done when"

- [x] All the main data (courses) lives in Firestore, under `users/{uid}/courses`.
- [x] A second account cannot see the first account's data (rules check `request.auth.uid == userId`).
- [x] Every screen that loads shows a loading state, an error state and an empty state.
- [x] Committed with git; no passwords or emails committed.


---

## 🛠️ Testing

Unit and widget tests cover time parsing, validation, clash detection logic, sorting rules, and the login screen:

```bash
flutter test
```

Static analysis (must be clean):

```bash
flutter analyze
```
