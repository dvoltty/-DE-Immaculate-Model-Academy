# DE’ Immaculate Model Academy LMS

A responsive, branded LMS / exam-coaching portal prototype for GitHub Pages. It includes a public academy website and front-end demonstrations of student, tutor and administrator dashboards.

## Included

- Public homepage, academy overview, exam programmes, boarding enquiry, pricing, contact and footer branding.
- Uploaded logos: `assets/header-logo.jpg` is used in the site header; `assets/home-emblem.jpg` is used as the homepage emblem.
- Student sign-up fields for Science / Art / Commercial / General, exam focus, multiple subjects, phone, email and plan selection.
- Separate role-based login views for students, tutors and admin.
- Ten seeded tutor demo accounts and one admin demo account.
- Student CBT interface: JAMB, WAEC, NECO and Post-UTME selectors; 2022–2026 year filters; 40 / 60 / 90 / 120 requested question-count settings; timed test, question navigation, answer selection, auto-marking and results history.
- A small set of original sample practice questions for demonstration. It is **not** a verified official JAMB / WAEC / NECO past-question archive.
- Tutor test creation, manual MCQ builder, PDF text extraction draft and admin publication approval.
- Admin user/tutor approval, suspension controls, examination review and results overview.
- AI study assistant demo, scientific calculator, notifications, class-link area, chat demo and local voice-note recording.
- Mobile responsive layout and contact / Boge Expression links.

## Deploy to your GitHub Pages website

1. Download and extract this project ZIP.
2. Open the repository that publishes `https://dvoltty.github.io/-DE-Immaculate-Model-Academy/`.
3. Back up the existing repository contents.
4. Upload the **contents** of this project folder (including `index.html`, `app.js`, `styles.css`, `assets/`, `README.md` and `supabase/schema.sql`) to the repository root. Do not upload the enclosing `de-immaculate-lms` folder as a nested folder unless you want the site at a subpath.
5. Commit to the branch/folder configured in GitHub Pages (commonly `main` / root).
6. Wait for the Pages deployment to complete, then open the website and test on desktop and mobile.

The site is plain HTML/CSS/JavaScript; no build step is required. It loads Math.js and PDF.js from public CDNs. A network connection is required for those libraries and Google Fonts.

## Demo login accounts

> **DEMO ONLY — NOT SECURE FOR REAL USERS.** The prototype stores demo users in browser `localStorage` and the current session in `sessionStorage`. Passwords are visible in the client-side source / browser storage. Do not use these credentials for production or put real student data into this version.

| Role | Username | Password |
|---|---|---|
| Administrator | `admin` | `Admin@12345` |
| Tutor 1 | `tutor01` | `Tutor@123` |
| Tutor 2 | `tutor02` | `Tutor@123` |
| Tutor 3 | `tutor03` | `Tutor@123` |
| Tutor 4 | `tutor04` | `Tutor@123` |
| Tutor 5 | `tutor05` | `Tutor@123` |
| Tutor 6 | `tutor06` | `Tutor@123` |
| Tutor 7 | `tutor07` | `Tutor@123` |
| Tutor 8 | `tutor08` | `Tutor@123` |
| Tutor 9 | `tutor09` | `Tutor@123` |
| Tutor 10 | `tutor10` | `Tutor@123` |

A student can register from the public site. New student accounts are pending approval until the admin approves them. For testing, log in as admin and open **Approvals**.

## Important content and CBT notes

- The site has selectable years 2022, 2023, 2024, 2025 and 2026 and can hold 40–120 question exams. The project does not claim to contain all official historical exam questions. No official question archive was provided with the request.
- Use question papers / answer keys that the academy owns or is licensed to use. Import the PDF in the tutor dashboard, check every extracted question and option, add the correct answer manually, and have an administrator approve the test. PDF parsing is best-effort and does not reliably infer answer keys.
- The starter bank contains a small number of original sample questions for selected subjects. A 40–120 question test needs a verified question bank of the selected length. Add the full question data through the tutor builder or a production question-bank import.
- The three pricing figures shown on the homepage are illustrative placeholders. Confirm and replace them with approved academy fees before publishing or collecting payments. Boarding is an enquiry, not a confirmed room/fee offer.
- The location, registration and academy description on the homepage are supplied by the site owner in the request. Confirm wording and details before public launch.

## Production requirements (not provided by GitHub Pages)

GitHub Pages is static hosting. It cannot safely provide a multi-user database, secure login, server-side permissions, payments, AI API keys, durable file storage, or WebRTC signalling on its own. The demo uses local browser storage, so data is not shared between users or devices and can be cleared by the browser.

For a real academy rollout, connect these services:

1. **Supabase (or equivalent):** Postgres database, Auth, Row Level Security, Storage for PDF/materials, and Realtime presence/messages. A starter SQL schema is in `supabase/schema.sql`. Review and test all RLS policies with a security professional before real student data is stored.
2. **Authentication:** Replace demo login with Supabase Auth / server-side sessions. Create roles in protected profile records. Never seed shared passwords in JavaScript. Admin accounts should be invited and require strong unique passwords and MFA.
3. **AI:** Add a server-side Edge Function / API route that calls your selected AI provider. Keep the API key in server secrets, enforce user limits and log usage safely. Never put an AI secret in `app.js`.
4. **Live video/audio:** Use a provider such as LiveKit, Jitsi or Zoom SDK. Issue short-lived room tokens server-side. Browser-to-browser WebRTC needs signalling, TURN/STUN and consent/permissions. The class area currently accepts an external HTTPS meeting link only.
5. **Chat and voice notes:** Store messages and audio in authenticated services with per-class access rules, upload limits, retention and moderation. Current chat is local demonstration state; voice notes are downloaded locally and are not sent.
6. **Payments:** Integrate Paystack or Flutterwave via a secure backend, verify payment webhooks server-side, and only then activate paid plans. The prototype does not take payments.
7. **Online presence and notifications:** Use authenticated realtime presence and server-generated notifications; the visible demo online counts are local estimates, not live connected-user data.
8. **Question bank:** Import reviewed question/answer data with provenance, exam, year, subject, topic, licence, and answer explanation. Restrict tutor access to their own drafts and require admin approval before publication.
9. **Backups and privacy:** Establish data protection notices, parental/guardian handling where appropriate, backups, audit logs, retention rules, incident response and Nigerian Data Protection Act compliance review.

## Suggested backend environment

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY` (public browser key only; protect data with RLS)
- `SUPABASE_SERVICE_ROLE_KEY` (server secret only; never expose in frontend)
- `AI_PROVIDER_API_KEY` (server secret only)
- `LIVEKIT_API_KEY` / `LIVEKIT_API_SECRET` (server secrets only)
- Payment provider secret and webhook verification key (server secrets only)

## Branding

- Phone: +234 806 704 7801
- Location: NTA–Ilawe Bypass Road, opposite Federal Polytechnic Ado-Ekiti Satellite Campus, Ado-Ekiti, Ekiti State, Nigeria
- Built by Boge Expression: https://oluwafemoli.github.io/boge-neurovascular-Framework-inteligence/


## Quick student demonstration accounts

Ten pre-approved student profiles are seeded into the browser's local demo data. Sign in from the Login window using any username below. The password for all ten is `Student@123`.

| Username | Student profile | Learning plan |
|---|---|---|
| student01 | Science · JAMB | Free access |
| student02 | Art · JAMB | Free access |
| student03 | Commercial · WAEC | Free access |
| student04 | Science · WAEC | Exam preparation (sample) |
| student05 | Art · NECO | Exam preparation (sample) |
| student06 | Commercial · JAMB | Exam preparation (sample) |
| student07 | Science · Post-UTME | Premium coaching (sample) |
| student08 | Art · JAMB | Premium coaching (sample) |
| student09 | General · NECO | Boarding enquiry |
| student10 | Science · JAMB | Boarding enquiry |

The login dialog includes quick-login buttons for these student profiles. These are demonstration profiles only; all browser data is local to the device and is not shared across users or devices. The displayed plan prices are illustrative, not confirmed academy fees.
