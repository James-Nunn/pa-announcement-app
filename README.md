# Schoo PA Announcement App
An iOS app for school announcements using Googles Firestore cloud database 

## This app
- Uses Firestore as a database for CRUD operations for user and announcement documents.
- Uses Firebase Authentication to sign in, sign up, and remember users.
- Uses CoreData to save drafts and remove announcements locally to prevent cluttering the UI.
- Uses UserNotification to send local notifications when announcements are made (Local as I do not have a Developer Account).
- Contains Observable classes to give the whole app access to the same instance of an object
- Uses my profanity filter code see here - [Profanity Filter](https://github.com/James-Nunn/profanity-checker)
- Extensions to structs (color, a CoreCata Entity, and string) to provide custom colours, functions to get data as array of string and check formatting of emails upon login.
- Enforces data types and rules to maintain integrity and elimiate user made errors.
- Uses NavigationStack to maintain a simple single screen application with constant view of announcements (UX).

## Video
[Click to Download](https://github.com/James-Nunn/pa-announcement-app/raw/main/App.mp4)
