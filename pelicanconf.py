from datetime import datetime
CURRENT_YEAR = datetime.now().year

AUTHOR = 'Thane Gill'
SITENAME = 'Thane Gill'
SITEURL = ''

PATH = 'content'
ARTICLE_PATHS = ['articles']
PAGE_PATHS = ['pages']

TIMEZONE = 'America/Los_Angeles'
DEFAULT_LANG = 'en'

THEME = 'themes/clean-blog'

# Feed
FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Social
TWITTER_USERNAME = 'thanegill'
GITHUB_USERNAME = 'thanegill'
EMAIL_ADDRESS = 'me@thanegill.com'

DEFAULT_PAGINATION = 10

ARTICLE_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/'
ARTICLE_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'

PAGE_URL = '{slug}/'
PAGE_SAVE_AS = '{slug}/index.html'

STATIC_PATHS = ['images']
