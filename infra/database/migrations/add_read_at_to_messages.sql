-- ============================================================================
-- Migration: Add read_at column to chat_messages
-- ============================================================================
-- This migration adds the read_at timestamp column to track when messages
-- are read, replacing the boolean is_read approach with precise timestamps.
-- ============================================================================

-- Add read_at column to chat_messages table
-- NULL means unread, non-NULL timestamp means read at that time
ALTER TABLE chat_messages 
ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITH TIME ZONE;

-- Create partial index for efficient unread message queries
-- This index only includes rows where read_at IS NULL (unread messages)
CREATE INDEX IF NOT EXISTS idx_chat_messages_unread 
ON chat_messages (conversation_id, sender_id, read_at) 
WHERE read_at IS NULL;

-- Create index on read_at for general queries on read status
CREATE INDEX IF NOT EXISTS idx_chat_messages_read_at 
ON chat_messages (read_at);

-- Data migration: if is_read column exists, migrate data to read_at
-- Set read_at to created_at for messages that were marked as read
UPDATE chat_messages 
SET read_at = created_at 
WHERE read_at IS NULL 
  AND is_read = true;
