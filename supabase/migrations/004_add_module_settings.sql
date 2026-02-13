-- Add settings column to business_subscriptions table
ALTER TABLE public.business_subscriptions 
ADD COLUMN IF NOT EXISTS settings jsonb DEFAULT '{}'::jsonb;

-- Comment on column
COMMENT ON COLUMN public.business_subscriptions.settings IS 'Configuration settings for the module';
