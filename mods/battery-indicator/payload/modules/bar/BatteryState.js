.pragma library

var lowThreshold = 20;
var mediumThreshold = 50;
function percentage(value, available) {
    return available && typeof value === "number" && isFinite(value) ? Math.max(0, Math.min(100, value)) : null;
}
function threshold(value) {
    return typeof value === "number" && isFinite(value) && value >= 20 && value <= 100 ? value : null;
}
function level(value) {
    return value === null ? "neutral" : value <= lowThreshold ? "red" : value <= mediumThreshold ? "yellow" : "green";
}
function limitReached(value, limit, ac, state, rate) {
    // No guess on Unknown/Discharging/PendingDischarge. A 0.5 percentage-point
    // tolerance handles UPower rounding; full at 100 is Full, never a limit.
    return value !== null && threshold(limit) !== null && limit < 100 && value < 100
        && value >= limit - 0.5 && ac === true
        && (state === "pending-charge" || state === "full")
        && typeof rate === "number" && isFinite(rate) && Math.abs(rate) < 0.1;
}
function status(value, state, ac, reached, limit) {
    if (value === null) return "Unavailable";
    if (reached) return "Charge limit reached · " + limit + "%";
    if (state === "charging") return "Charging";
    if (state === "full") return "Full";
    if (state === "discharging" || state === "pending-discharge") return "Discharging";
    if (ac === true && state === "pending-charge") return "AC connected · Not charging";
    if (state === "empty") return "Empty";
    return "State unavailable";
}
function tooltip(value, description) {
    return value === null ? "Battery unavailable" : "Battery: " + Math.round(value) + "%\n" + description;
}
