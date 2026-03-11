"""
Campus AI Assistant — Notification Service

Handles sending push notifications to students via Firebase Cloud Messaging (FCM).
Filters recipients based on their category preferences in the public.users table.
"""

import json
import logging
import os
from typing import List, Optional

import firebase_admin
from firebase_admin import credentials, messaging
from supabase import Client

from app.config import get_settings

settings = get_settings()
logger = logging.getLogger(__name__)

# Initialize Firebase Admin SDK
firebase_available = False
try:
    if os.path.exists(settings.firebase_service_account_path):
        cred = credentials.Certificate(settings.firebase_service_account_path)
        firebase_admin.initialize_app(cred)
        firebase_available = True
        logger.info("Firebase Admin SDK initialized successfully.")
    else:
        logger.warning(
            f"Firebase service account file not found at {settings.firebase_service_account_path}. "
            "Push notifications will be disabled."
        )
except Exception as e:
    logger.error(f"Failed to initialize Firebase Admin SDK: {e}")


async def send_event_notification(
    db: Client,
    event_title: str,
    event_category: str,
    event_id: str,
) -> int:
    """Send push notifications to all users who have opted into the given category.
    
    Returns the count of notifications successfully sent.
    """
    if not firebase_available:
        logger.warning("Notification skipped: Firebase not initialized.")
        return 0

    try:
        # 1. Fetch users who want notifications for this category
        # notification_preferences is a JSONB: {"Academic": true, ...}
        # In SQL: profiles.notification_preferences->>event_category = 'true'
        
        # Note: Supabase-py doesn't have a clean way for JSONB arrows in .select() filters yet
        # So we fetch users and tokens and filter in Python or use a raw RPC/query
        
        # Let's use a join to get tokens for users who have the preference enabled
        # We'll fetch all tokens and then join with user preferences
        tokens_result = (
            db.table("device_tokens")
            .select("token, user_id, users(notification_preferences)")
            .execute()
        )
        
        target_tokens = []
        for row in (tokens_result.data or []):
            prefs = (row.get("users") or {}).get("notification_preferences", {})
            if prefs.get(event_category) is True:
                target_tokens.append(row["token"])

        if not target_tokens:
            logger.info(f"No target tokens for category {event_category}.")
            return 0

        # 2. Prepare the message
        # FCM allows batch sending up to 500 messages at once
        sent_count = 0
        for i in range(0, len(target_tokens), 500):
            batch = target_tokens[i : i + 500]
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=f"New {event_category} Event!",
                    body=event_title,
                ),
                data={
                    "type": "event_update",
                    "event_id": event_id,
                    "category": event_category,
                },
                tokens=batch,
            )
            
            response = messaging.send_multicast(message)
            sent_count += response.success_count
            
            if response.failure_count > 0:
                logger.warning(f"Failed to send {response.failure_count} notifications in batch.")

        return sent_count

    except Exception as e:
        logger.error(f"Error in send_event_notification: {e}")
        return 0
