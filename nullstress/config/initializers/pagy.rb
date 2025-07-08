require "pagy"

# Only load what you need in an API-only app
require "pagy/extras/metadata"  # For JSON API-friendly meta info
require "pagy/extras/overflow"  # For clean handling of out-of-bounds pages

# Global defaults (safe for API responses)
Pagy::DEFAULT[:items] = 100               # Default per-page
Pagy::DEFAULT[:max_items] = 500           # Prevent abuse
Pagy::DEFAULT[:overflow] = :last_page     # Don’t crash on overflow
Pagy::DEFAULT[:page_param] = :page        # Use ?page=
Pagy::DEFAULT[:items_param] = :per_page   # Use ?per_page=
