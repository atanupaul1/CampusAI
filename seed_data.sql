-- ============================================================
-- Campus AI Assistant — Sample Seed Data
-- Run this in the Supabase SQL Editor AFTER the migration.
-- Populates campus_events and campus_faqs with demo data.
-- ============================================================

-- --------------------------------------------------------
-- Sample Campus Events
-- --------------------------------------------------------
INSERT INTO public.campus_events (title, description, location, start_time, end_time, category, source_url)
VALUES
  (
    'Annual Tech Fest 2026',
    'Join us for a 3-day technology festival featuring hackathons, workshops, guest lectures from industry leaders, and exciting project showcases by students.',
    'Main Auditorium, Block A',
    '2026-03-20 09:00:00+05:30',
    '2026-03-22 18:00:00+05:30',
    'Academic',
    'https://university.edu/events/techfest2026'
  ),
  (
    'Spring Cultural Night',
    'An evening of music, dance, drama, and art performances by student clubs. Food stalls and fun activities included!',
    'Open Air Theatre',
    '2026-03-15 17:00:00+05:30',
    '2026-03-15 22:00:00+05:30',
    'Social',
    'https://university.edu/events/culturalnight'
  ),
  (
    'Inter-College Cricket Tournament',
    'Annual cricket tournament featuring teams from 8 colleges. Come cheer for our team!',
    'University Sports Ground',
    '2026-03-25 08:00:00+05:30',
    '2026-03-27 18:00:00+05:30',
    'Sports',
    'https://university.edu/events/cricket2026'
  ),
  (
    'AI & Machine Learning Workshop',
    'Hands-on workshop on building ML models with Python and TensorFlow. Bring your laptop! Open to all departments.',
    'Computer Lab 3, Block C',
    '2026-03-18 10:00:00+05:30',
    '2026-03-18 16:00:00+05:30',
    'Workshop',
    'https://university.edu/events/ml-workshop'
  ),
  (
    'Guest Lecture: Future of Renewable Energy',
    'Dr. Priya Sharma from IIT Delhi discusses the latest breakthroughs in solar and wind energy technology.',
    'Seminar Hall 2, Block B',
    '2026-03-14 14:00:00+05:30',
    '2026-03-14 16:00:00+05:30',
    'Seminar',
    'https://university.edu/events/renewable-energy-talk'
  ),
  (
    'Campus Blood Donation Drive',
    'Partner event with Red Cross. All donors receive a certificate and refreshments. Walk-ins welcome.',
    'Health Centre, Ground Floor',
    '2026-03-12 09:00:00+05:30',
    '2026-03-12 15:00:00+05:30',
    'Social',
    'https://university.edu/events/blood-drive'
  ),
  (
    'End-Semester Exam Schedule Released',
    'Final examination timetable for Spring 2026 is now available. Check the academic portal for your personalized schedule.',
    'Online — Academic Portal',
    '2026-04-15 09:00:00+05:30',
    '2026-04-30 17:00:00+05:30',
    'Academic',
    'https://university.edu/exams/spring2026'
  ),
  (
    'Resume Building & Interview Prep Session',
    'Career Services team hosts a practical session on crafting the perfect resume and acing technical interviews.',
    'Placement Cell, Admin Block',
    '2026-03-16 11:00:00+05:30',
    '2026-03-16 13:00:00+05:30',
    'Workshop',
    'https://university.edu/events/career-prep'
  );

-- --------------------------------------------------------
-- Sample Campus FAQs
-- --------------------------------------------------------
INSERT INTO public.campus_faqs (question, answer, category)
VALUES
  (
    'What are the library timings?',
    'The central library is open Monday to Saturday, 8:00 AM to 10:00 PM. On Sundays, it is open from 10:00 AM to 6:00 PM.',
    'Facilities'
  ),
  (
    'How do I apply for a hostel room?',
    'Hostel applications open in June each year. Visit the Student Welfare Office (Admin Block, Room 104) or apply online through the student portal under "Hostel Services".',
    'Hostel'
  ),
  (
    'Where is the placement cell?',
    'The Placement Cell is located on the 2nd floor of the Admin Block. Office hours are 9:00 AM to 5:00 PM, Monday to Friday. Email: placements@university.edu',
    'Career'
  ),
  (
    'How can I get my ID card replaced?',
    'Visit the Student Affairs Office with a passport-size photo and a written application. Replacement fee is ₹100. Processing takes 3-5 working days.',
    'Administrative'
  ),
  (
    'What is the fee payment deadline?',
    'Fee payment for the Spring 2026 semester is due by March 31, 2026. Late fees of ₹500 per week apply after the deadline. Pay via the student portal or at the accounts office.',
    'Fees'
  ),
  (
    'Is there Wi-Fi on campus?',
    'Yes! Free Wi-Fi is available across all academic blocks, the library, and hostels. Connect to "CampusNet" and log in with your student ID and password.',
    'Facilities'
  ),
  (
    'How do I join a student club?',
    'Visit the Student Activities Centre (near the canteen) during club registration week (first week of each semester). You can also check the student portal for open registrations.',
    'Student Life'
  ),
  (
    'Where can I get medical help on campus?',
    'The Campus Health Centre is located next to the Main Gate. It is open 24/7 for emergencies. Regular OPD hours are 9:00 AM to 5:00 PM. A doctor and nurse are available at all times.',
    'Health'
  ),
  (
    'What are the canteen timings?',
    'The main canteen operates from 7:30 AM to 9:30 PM. The food court near Block D is open from 10:00 AM to 8:00 PM.',
    'Facilities'
  ),
  (
    'How do I access my academic transcript?',
    'Log into the student portal → Academics → Transcripts. You can download an unofficial transcript for free. For an official sealed transcript, apply at the Examination Office (₹200 per copy).',
    'Academic'
  );
