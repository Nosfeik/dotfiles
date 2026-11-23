// nosfeik — Firefox user.js
// Applied on every startup. Remove a line here AND reset it in about:config to undo.

// ---------- theme / userChrome ----------
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
user_pref("layout.css.prefers-color-scheme.content-override", 0); // dark websites when supported
user_pref("browser.theme.content-theme", 0);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1); // compact
user_pref("browser.tabs.inTitlebar", 1);
user_pref("browser.display.background_color.dark", "#16181d");

// ---------- lab domains: resolve instead of searching ----------
// "headless.htb" -> http://headless.htb (uses /etc/hosts / DNS) instead of a web search
user_pref("browser.fixup.domainsuffixwhitelist.htb", true);
user_pref("browser.fixup.domainsuffixwhitelist.thm", true);
user_pref("browser.fixup.domainsuffixwhitelist.vl", true);
user_pref("browser.fixup.domainsuffixwhitelist.local", true);
user_pref("browser.fixup.domainsuffixwhitelist.lab", true);
user_pref("browser.fixup.domainsuffixwhitelist.lan", true);
user_pref("browser.fixup.domainsuffixwhitelist.internal", true);
user_pref("browser.fixup.domainsuffixwhitelist.corp", true);
user_pref("browser.fixup.domainsuffixwhitelist.test", true);
user_pref("browser.fixup.domainsuffixwhitelist.home", true);
// single words (e.g. "dc01") try DNS first
user_pref("browser.fixup.dns_first_for_single_words", true);
// don't rewrite "foo" -> "www.foo.com"
user_pref("browser.fixup.alternate.enabled", false);
// lab boxes are usually plain http: don't force https first
user_pref("dom.security.https_first", false);
user_pref("dom.security.https_first_schemeless", false);
// show the full URL (scheme, trailing slash)
user_pref("browser.urlbar.trimURLs", false);
user_pref("browser.urlbar.trimHttps", false);

// ---------- clean new tab / home ----------
// blank new tab + blank home (no widgets, shortcuts, second search box)
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "file:///home/nosfeik/.config/firefox-startpage/index.html");
user_pref("browser.startup.page", 1);
user_pref("browser.toolbars.bookmarks.visibility", "never");
user_pref("browser.newtabpage.activity-stream.widgets.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.system.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.weather.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.clocks.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.crossword.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.system.crossword.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredCheckboxes", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.system.showWeather", false);
user_pref("browser.newtabpage.activity-stream.widgets.lists.enabled", false);
user_pref("browser.newtabpage.activity-stream.widgets.focusTimer.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);
user_pref("browser.newtabpage.activity-stream.showRecentSaves", false);
user_pref("browser.newtabpage.activity-stream.newtabWallpapers.enabled", false);
user_pref("browser.newtabpage.activity-stream.topSitesRows", 1);
user_pref("extensions.pocket.enabled", false);

// ---------- clean urlbar ----------
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.trending", false);
user_pref("browser.urlbar.suggest.weather", false);
user_pref("browser.urlbar.suggest.yelp", false);
user_pref("browser.urlbar.suggest.mdn", false);
user_pref("browser.urlbar.suggest.addons", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.showSearchTerms.enabled", false);

// ---------- less noise ----------
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.tabs.firefox-view", false);
user_pref("browser.tabs.tabmanager.enabled", false);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.sidebar", false);
user_pref("browser.ml.linkPreview.enabled", false);
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("extensions.getAddons.showPane", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("identity.fxaccounts.toolbar.enabled", false);
user_pref("browser.translations.automaticallyPopup", false);

// ---------- telemetry off ----------
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.usage.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

// ---------- misc ----------
user_pref("general.smoothScroll", true);
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.download.useDownloadDir", false); // ask where to save
user_pref("browser.download.alwaysOpenPanel", false);

// ---------- no history ----------
// don't record visited pages, searches or form entries (bookmarks, logins and cookies stay)
user_pref("places.history.enabled", false);
user_pref("browser.formfill.enable", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.sessionstore.resume_from_crash", true);
// wipe whatever history/downloads/form data exists when Firefox closes
user_pref("privacy.history.custom", true);
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", true);
user_pref("privacy.clearOnShutdown_v2.formdata", true);
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", true);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
user_pref("privacy.clearOnShutdown_v2.cache", false);
user_pref("privacy.clearOnShutdown_v2.siteSettings", false);
user_pref("privacy.clearOnShutdown.history", true);
user_pref("privacy.clearOnShutdown.downloads", true);
user_pref("privacy.clearOnShutdown.formdata", true);
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.clearOnShutdown.sessions", false);
user_pref("privacy.clearOnShutdown.offlineApps", false);
user_pref("privacy.clearOnShutdown.cache", false);
user_pref("privacy.clearOnShutdown.siteSettings", false);
