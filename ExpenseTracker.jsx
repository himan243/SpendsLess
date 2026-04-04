import { useState, useEffect, useRef } from "react";

const CATS = [
  { id: "food", l: "Food", e: "🍔", c: "#FF6B6B" },
  { id: "delivery", l: "Delivery", e: "🛵", c: "#FF8A65" },
  { id: "travel", l: "Travel", e: "✈️", c: "#64B5F6" },
  { id: "shopping", l: "Shopping", e: "🛍️", c: "#CE93D8" },
  { id: "entertainment", l: "Fun", e: "🎮", c: "#4DB6AC" },
  { id: "health", l: "Health", e: "💊", c: "#81C784" },
  { id: "bills", l: "Bills", e: "💡", c: "#FFD54F" },
  { id: "other", l: "Other", e: "✨", c: "#F06292" },
];

const METHODS = [
  { id: "upi", l: "UPI", e: "📲", desc: "GPay, PhonePe…" },
  { id: "card", l: "Card", e: "💳", desc: "Debit / Credit" },
  { id: "cash", l: "Cash", e: "💵", desc: "Physical ₹" },
];

function emojiFor(pct) {
  if (pct === 0) return { e: "😴", msg: "nothing spent yet~", clr: "#6b7280" };
  if (pct <= 15) return { e: "😎", msg: "slay, you're saving fr", clr: "#10b981" };
  if (pct <= 35) return { e: "😊", msg: "vibing, all good bestie", clr: "#22c55e" };
  if (pct <= 55) return { e: "🙂", msg: "mid spend, keep it chill", clr: "#eab308" };
  if (pct <= 70) return { e: "😬", msg: "getting spenny ngl", clr: "#f59e0b" };
  if (pct <= 85) return { e: "😰", msg: "bro stop fr fr", clr: "#f97316" };
  if (pct <= 100) return { e: "🤯", msg: "you absolutely cooked rn", clr: "#ef4444" };
  return { e: "💀", msg: "budget? never heard of it", clr: "#dc2626" };
}

function todayStr() { return new Date().toISOString().split("T")[0]; }
function monthStr() { return new Date().toISOString().slice(0, 7); }
function yearStr() { return new Date().getFullYear().toString(); }
function fmt(n) { return "₹" + Number(n).toLocaleString("en-IN", { maximumFractionDigits: 0 }); }
function timeStr(ts) { return new Date(ts).toLocaleTimeString("en-IN", { hour: "2-digit", minute: "2-digit" }); }

const CSS = `
  @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800;900&display=swap');
  *{box-sizing:border-box;margin:0;padding:0;}
  ::-webkit-scrollbar{width:0;}
  input[type=number]::-webkit-inner-spin-button{-webkit-appearance:none;}

  @keyframes emojiBounce {
    0%{transform:scale(1) rotate(0deg);}
    25%{transform:scale(1.35) rotate(-8deg);}
    50%{transform:scale(1.2) rotate(6deg);}
    75%{transform:scale(1.3) rotate(-3deg);}
    100%{transform:scale(1) rotate(0deg);}
  }
  @keyframes slideUp {
    from{transform:translateY(28px);opacity:0;}
    to{transform:translateY(0);opacity:1;}
  }
  @keyframes pop {
    0%{transform:scale(0.6);opacity:0;}
    60%{transform:scale(1.15);}
    100%{transform:scale(1);opacity:1;}
  }
  @keyframes barGrow {
    from{width:0;}
  }
  @keyframes successPulse {
    0%,100%{box-shadow:0 0 0 0 rgba(16,185,129,0);}
    50%{box-shadow:0 0 0 16px rgba(16,185,129,0.12);}
  }
  @keyframes fadeIn {
    from{opacity:0;}to{opacity:1;}
  }
  @keyframes float {
    0%,100%{transform:translateY(0);}
    50%{transform:translateY(-6px);}
  }
  @keyframes bgShift {
    0%{background-position:0% 50%;}
    50%{background-position:100% 50%;}
    100%{background-position:0% 50%;}
  }

  .slide-up{animation:slideUp 0.32s cubic-bezier(0.22,1,0.36,1) both;}
  .pop{animation:pop 0.35s cubic-bezier(0.22,1,0.36,1) both;}
  .emoji-bounce{animation:emojiBounce 0.55s cubic-bezier(0.22,1,0.36,1) both;}
  .fade-in{animation:fadeIn 0.25s ease both;}
  .float{animation:float 3s ease-in-out infinite;}
`;

const BG = "#08080f";
const CARD = "rgba(255,255,255,0.04)";
const BORDER = "rgba(255,255,255,0.08)";
const ACCENT = "#7c6bff";
const TEXT = "#f0f0fa";
const MUTED = "rgba(240,240,250,0.42)";

function Card({ children, style = {}, glow }) {
  return (
    <div style={{
      background: CARD,
      border: `1px solid ${BORDER}`,
      borderRadius: 20,
      padding: "16px 18px",
      boxShadow: glow ? `0 0 24px ${glow}22` : "none",
      ...style,
    }}>{children}</div>
  );
}

function PillBtn({ active, onClick, children, color = ACCENT }) {
  return (
    <button onClick={onClick} style={{
      background: active ? `${color}20` : "rgba(255,255,255,0.03)",
      border: active ? `1.5px solid ${color}55` : `1px solid ${BORDER}`,
      borderRadius: 12,
      color: active ? color : MUTED,
      fontFamily: "inherit",
      fontSize: 13,
      fontWeight: active ? 700 : 500,
      padding: "8px 16px",
      cursor: "pointer",
      transition: "all 0.15s",
      transform: active ? "scale(1.04)" : "scale(1)",
    }}>{children}</button>
  );
}

export default function App() {
  const [screen, setScreen] = useState("home");
  const [limit, setLimit] = useState(2000);
  const [expenses, setExpenses] = useState([]);
  const [loaded, setLoaded] = useState(false);

  const [formAmt, setFormAmt] = useState("");
  const [formCat, setFormCat] = useState("");
  const [formMethod, setFormMethod] = useState("");
  const [formNote, setFormNote] = useState("");
  const [step, setStep] = useState(0);

  const [editLimit, setEditLimit] = useState(false);
  const [limitDraft, setLimitDraft] = useState("");
  const [statsTab, setStatsTab] = useState("month");
  const [justAdded, setJustAdded] = useState(false);
  const [emojiKey, setEmojiKey] = useState(0);
  const [deletedId, setDeletedId] = useState(null);

  useEffect(() => {
    (async () => {
      try {
        const l = await window.storage.get("xpns_v3_limit");
        if (l) setLimit(+l.value);
        const e = await window.storage.get("xpns_v3_data");
        if (e) setExpenses(JSON.parse(e.value));
      } catch (_) {}
      setLoaded(true);
    })();
  }, []);

  useEffect(() => {
    if (loaded) window.storage.set("xpns_v3_data", JSON.stringify(expenses)).catch(() => {});
  }, [expenses, loaded]);

  useEffect(() => {
    if (loaded) window.storage.set("xpns_v3_limit", String(limit)).catch(() => {});
  }, [limit, loaded]);

  const tod = todayStr();
  const todayExps = expenses.filter(e => e.date === tod);
  const todayTotal = todayExps.reduce((s, e) => s + e.amount, 0);
  const pct = limit > 0 ? Math.min((todayTotal / limit) * 100, 110) : 0;
  const ed = emojiFor(pct);

  const barColor =
    pct <= 40
      ? "linear-gradient(90deg,#10b981,#22c55e)"
      : pct <= 70
      ? "linear-gradient(90deg,#22c55e,#eab308,#f59e0b)"
      : "linear-gradient(90deg,#f97316,#ef4444,#dc2626)";

  function handleAddExpense() {
    if (!formAmt || !formCat || !formMethod) return;
    const exp = {
      id: Date.now(),
      amount: parseFloat(formAmt),
      cat: formCat,
      method: formMethod,
      note: formNote.trim(),
      date: tod,
      ts: Date.now(),
    };
    setExpenses(p => [exp, ...p]);
    setFormAmt(""); setFormCat(""); setFormMethod(""); setFormNote("");
    setStep(0);
    setJustAdded(true);
    setEmojiKey(k => k + 1);
    setTimeout(() => { setJustAdded(false); setScreen("home"); }, 1600);
  }

  function deleteExp(id) {
    setDeletedId(id);
    setTimeout(() => {
      setExpenses(p => p.filter(e => e.id !== id));
      setDeletedId(null);
      setEmojiKey(k => k + 1);
    }, 260);
  }

  function goHome() {
    setScreen("home"); setStep(0);
    setFormAmt(""); setFormCat(""); setFormMethod(""); setFormNote("");
  }

  // ─── HOME SCREEN ───────────────────────────────────────────────────────────
  if (screen === "home") {
    return (
      <div style={{ minHeight: "100vh", background: BG, fontFamily: "'Plus Jakarta Sans',sans-serif", color: TEXT, maxWidth: 430, margin: "0 auto", position: "relative" }}>
        <style>{CSS}</style>

        {/* Top glow blob */}
        <div style={{ position: "absolute", top: -80, left: "50%", transform: "translateX(-50%)", width: 300, height: 300, borderRadius: "50%", background: `radial-gradient(circle, ${ed.clr}18 0%, transparent 70%)`, pointerEvents: "none", transition: "background 1s ease" }} />

        {/* Header Card */}
        <div style={{ padding: "52px 20px 20px", position: "relative" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 20 }}>

            {/* Left: limit + spent */}
            <div>
              <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 4 }}>
                Daily Limit
              </div>
              {editLimit ? (
                <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
                  <input
                    autoFocus
                    type="number"
                    value={limitDraft}
                    onChange={e => setLimitDraft(e.target.value)}
                    onKeyDown={e => {
                      if (e.key === "Enter") { const v = parseFloat(limitDraft); if (v > 0) setLimit(v); setEditLimit(false); setLimitDraft(""); }
                      if (e.key === "Escape") { setEditLimit(false); setLimitDraft(""); }
                    }}
                    placeholder={String(limit)}
                    style={{ background: "rgba(124,107,255,0.12)", border: "1.5px solid rgba(124,107,255,0.45)", borderRadius: 12, color: TEXT, fontSize: 22, fontWeight: 800, padding: "4px 10px", width: 130, outline: "none", fontFamily: "inherit" }}
                  />
                  <button onClick={() => { const v = parseFloat(limitDraft); if (v > 0) setLimit(v); setEditLimit(false); setLimitDraft(""); }}
                    style={{ background: ACCENT, border: "none", borderRadius: 10, color: "#fff", padding: "6px 12px", cursor: "pointer", fontSize: 13, fontWeight: 700, fontFamily: "inherit" }}>
                    Set
                  </button>
                </div>
              ) : (
                <button onClick={() => { setEditLimit(true); setLimitDraft(String(limit)); }}
                  style={{ background: "none", border: "none", cursor: "pointer", padding: 0, display: "flex", alignItems: "center", gap: 8 }}>
                  <span style={{ fontSize: 26, fontWeight: 900, color: TEXT }}>{fmt(limit)}</span>
                  <span style={{ fontSize: 11, color: "rgba(124,107,255,0.8)", background: "rgba(124,107,255,0.12)", padding: "3px 8px", borderRadius: 7, fontWeight: 700 }}>edit</span>
                </button>
              )}
              <div style={{ fontSize: 13, color: MUTED, marginTop: 6 }}>
                <span style={{ color: TEXT, fontWeight: 800 }}>{fmt(todayTotal)}</span>
                {" "}spent today
              </div>
            </div>

            {/* Right: animated emoji */}
            <div key={emojiKey} className="emoji-bounce" style={{ textAlign: "center", paddingTop: 4 }}>
              <div style={{
                fontSize: 56, lineHeight: 1,
                filter: pct > 85 ? `drop-shadow(0 0 12px ${ed.clr}80)` : pct > 60 ? `drop-shadow(0 0 8px ${ed.clr}50)` : "none",
                transition: "filter 0.4s ease",
              }}>{ed.e}</div>
            </div>
          </div>

          {/* Progress bar */}
          <div style={{ marginBottom: 6 }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8, alignItems: "center" }}>
              <span style={{ fontSize: 13, color: ed.clr, fontWeight: 700 }}>{ed.msg}</span>
              <span style={{ fontSize: 12, color: MUTED, fontWeight: 600 }}>{Math.min(pct, 100).toFixed(0)}%</span>
            </div>
            <div style={{ height: 9, background: "rgba(255,255,255,0.06)", borderRadius: 99, overflow: "hidden" }}>
              <div style={{
                height: "100%", width: `${Math.min(pct, 100)}%`,
                background: barColor, borderRadius: 99,
                transition: "width 0.7s cubic-bezier(0.34,1.56,0.64,1), background 0.8s ease",
                boxShadow: pct > 10 ? `0 0 12px ${ed.clr}55` : "none",
              }} />
            </div>
          </div>
        </div>

        {/* Today's transactions */}
        <div style={{ padding: "4px 20px 100px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 14 }}>
            <span style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700 }}>Today</span>
            <span style={{ fontSize: 12, color: "rgba(240,240,250,0.25)" }}>{todayExps.length} txn{todayExps.length !== 1 ? "s" : ""}</span>
          </div>

          {todayExps.length === 0 ? (
            <div className="fade-in" style={{ textAlign: "center", padding: "44px 20px", color: "rgba(240,240,250,0.2)" }}>
              <div className="float" style={{ fontSize: 48, marginBottom: 10 }}>🫙</div>
              <div style={{ fontSize: 15, fontWeight: 600 }}>no spend today, bestie</div>
              <div style={{ fontSize: 12, marginTop: 6, color: "rgba(240,240,250,0.15)" }}>keep that up or tap + to log one</div>
            </div>
          ) : (
            <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              {todayExps.map((exp, i) => {
                const cat = CATS.find(c => c.id === exp.cat) || CATS[7];
                const mth = METHODS.find(m => m.id === exp.method);
                const isDeleting = deletedId === exp.id;
                return (
                  <div key={exp.id} className="slide-up"
                    style={{
                      animationDelay: `${i * 0.04}s`,
                      background: CARD, border: `1px solid ${BORDER}`, borderRadius: 18,
                      padding: "13px 14px", display: "flex", alignItems: "center", gap: 12,
                      opacity: isDeleting ? 0 : 1, transform: isDeleting ? "translateX(30px)" : "none",
                      transition: "opacity 0.25s, transform 0.25s",
                    }}>
                    <div style={{
                      width: 46, height: 46, borderRadius: 14, flexShrink: 0,
                      background: `${cat.c}15`, border: `1px solid ${cat.c}28`,
                      display: "flex", alignItems: "center", justifyContent: "center", fontSize: 24,
                    }}>{cat.e}</div>

                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 3 }}>
                        <span style={{ fontWeight: 800, fontSize: 16 }}>{fmt(exp.amount)}</span>
                        <span style={{ fontSize: 11, background: `${cat.c}18`, color: cat.c, padding: "2px 7px", borderRadius: 6, fontWeight: 700 }}>{cat.l}</span>
                        {mth && <span style={{ fontSize: 14 }}>{mth.e}</span>}
                      </div>
                      {exp.note && <div style={{ fontSize: 12, color: MUTED, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{exp.note}</div>}
                    </div>

                    <div style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 6 }}>
                      <span style={{ fontSize: 11, color: "rgba(240,240,250,0.25)" }}>{timeStr(exp.ts)}</span>
                      <button onClick={() => deleteExp(exp.id)} style={{ background: "rgba(239,68,68,0.08)", border: "none", borderRadius: 7, cursor: "pointer", color: "rgba(239,68,68,0.55)", fontSize: 15, width: 26, height: 26, display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.15s" }}
                        onMouseEnter={e => e.currentTarget.style.background = "rgba(239,68,68,0.18)"}
                        onMouseLeave={e => e.currentTarget.style.background = "rgba(239,68,68,0.08)"}
                      >×</button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Bottom nav */}
        <div style={{
          position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)",
          width: "100%", maxWidth: 430,
          background: "rgba(8,8,15,0.88)", backdropFilter: "blur(24px)",
          borderTop: `1px solid ${BORDER}`, padding: "10px 16px 24px",
          display: "flex", gap: 10,
        }}>
          <button onClick={() => setScreen("stats")} style={{
            flex: 1, background: CARD, border: `1px solid ${BORDER}`,
            borderRadius: 14, padding: "11px", color: MUTED, cursor: "pointer",
            fontFamily: "inherit", fontSize: 14, fontWeight: 700,
            display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
            transition: "all 0.15s",
          }}>
            📊 Stats
          </button>
          <button onClick={() => setScreen("add")} style={{
            flex: 2.2,
            background: "linear-gradient(135deg,#7c6bff 0%,#9d4edd 100%)",
            border: "none", borderRadius: 14, padding: "13px",
            color: "#fff", cursor: "pointer",
            fontFamily: "inherit", fontSize: 15, fontWeight: 900,
            boxShadow: "0 4px 22px rgba(124,107,255,0.38)",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 6,
            letterSpacing: "0.01em",
          }}>
            + Add Expense
          </button>
        </div>
      </div>
    );
  }

  // ─── ADD SCREEN ────────────────────────────────────────────────────────────
  if (screen === "add") {
    const canNext0 = formAmt && parseFloat(formAmt) > 0;
    const canNext1 = !!formCat;
    const canAdd = canNext0 && canNext1 && !!formMethod;
    const selCat = CATS.find(c => c.id === formCat);
    const selMth = METHODS.find(m => m.id === formMethod);

    return (
      <div style={{ minHeight: "100vh", background: BG, fontFamily: "'Plus Jakarta Sans',sans-serif", color: TEXT, maxWidth: 430, margin: "0 auto" }}>
        <style>{CSS}</style>

        {/* Success overlay */}
        {justAdded && (
          <div style={{ position: "fixed", inset: 0, zIndex: 200, background: "rgba(8,8,15,0.96)", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 14 }}>
            <div className="pop" style={{ fontSize: 88 }}>🎉</div>
            <div style={{ fontSize: 20, fontWeight: 800, color: "#10b981", animation: "successPulse 1s ease infinite" }}>logged, no cap ✓</div>
          </div>
        )}

        {/* Header */}
        <div style={{ padding: "52px 20px 12px", display: "flex", alignItems: "center", gap: 14 }}>
          <button onClick={goHome} style={{ background: "rgba(255,255,255,0.05)", border: `1px solid ${BORDER}`, borderRadius: 12, width: 40, height: 40, cursor: "pointer", color: TEXT, fontSize: 20, display: "flex", alignItems: "center", justifyContent: "center" }}>
            ←
          </button>
          <div>
            <div style={{ fontSize: 20, fontWeight: 900 }}>log the spend 💸</div>
            <div style={{ fontSize: 12, color: MUTED }}>step {step + 1} of 3</div>
          </div>
        </div>

        {/* Step dots */}
        <div style={{ padding: "0 20px 24px", display: "flex", gap: 6 }}>
          {[0, 1, 2].map(i => (
            <div key={i} style={{
              height: 3, flex: 1, borderRadius: 99,
              background: i <= step ? ACCENT : "rgba(255,255,255,0.08)",
              boxShadow: i === step ? `0 0 8px ${ACCENT}80` : "none",
              transition: "all 0.35s ease",
            }} />
          ))}
        </div>

        <div style={{ padding: "0 20px", paddingBottom: 40 }}>

          {/* ── Step 0: Amount ── */}
          {step === 0 && (
            <div className="slide-up">
              <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 14 }}>how much did you spend?</div>
              <div style={{ position: "relative", marginBottom: 20 }}>
                <span style={{ position: "absolute", top: "50%", left: 20, transform: "translateY(-50%)", fontSize: 34, fontWeight: 900, color: "rgba(240,240,250,0.18)", pointerEvents: "none" }}>₹</span>
                <input
                  autoFocus type="number" value={formAmt}
                  onChange={e => setFormAmt(e.target.value)}
                  placeholder="0"
                  style={{ width: "100%", background: "rgba(255,255,255,0.04)", border: `1px solid ${BORDER}`, borderRadius: 20, color: TEXT, fontSize: 44, fontWeight: 900, padding: "20px 20px 20px 58px", outline: "none", fontFamily: "inherit", transition: "border 0.2s" }}
                  onFocus={e => e.target.style.border = `1px solid rgba(124,107,255,0.6)`}
                  onBlur={e => e.target.style.border = `1px solid ${BORDER}`}
                />
              </div>

              {/* Quick amounts */}
              <div style={{ display: "flex", gap: 8, marginBottom: 28, flexWrap: "wrap" }}>
                {[50, 100, 200, 500, 1000, 2000].map(q => (
                  <button key={q} onClick={() => setFormAmt(String(q))} style={{
                    background: formAmt === String(q) ? "rgba(124,107,255,0.18)" : "rgba(255,255,255,0.04)",
                    border: formAmt === String(q) ? `1.5px solid rgba(124,107,255,0.5)` : `1px solid ${BORDER}`,
                    borderRadius: 10, padding: "8px 14px",
                    color: formAmt === String(q) ? "#a78bfa" : MUTED,
                    cursor: "pointer", fontFamily: "inherit", fontSize: 14, fontWeight: 700,
                    transition: "all 0.15s",
                  }}>₹{q}</button>
                ))}
              </div>

              <button disabled={!canNext0} onClick={() => setStep(1)} style={{
                width: "100%", padding: "15px", borderRadius: 16,
                background: canNext0 ? "linear-gradient(135deg,#7c6bff,#9d4edd)" : "rgba(255,255,255,0.05)",
                border: "none", color: canNext0 ? "#fff" : "rgba(240,240,250,0.2)",
                fontSize: 16, fontWeight: 900, cursor: canNext0 ? "pointer" : "not-allowed",
                fontFamily: "inherit", boxShadow: canNext0 ? "0 4px 20px rgba(124,107,255,0.32)" : "none",
                transition: "all 0.2s", letterSpacing: "0.01em",
              }}>Next →</button>
            </div>
          )}

          {/* ── Step 1: Category ── */}
          {step === 1 && (
            <div className="slide-up">
              <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 14 }}>where'd the money go?</div>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: 10, marginBottom: 28 }}>
                {CATS.map(cat => (
                  <button key={cat.id} onClick={() => setFormCat(cat.id)} style={{
                    background: formCat === cat.id ? `${cat.c}1a` : "rgba(255,255,255,0.03)",
                    border: formCat === cat.id ? `1.5px solid ${cat.c}55` : `1px solid ${BORDER}`,
                    borderRadius: 16, padding: "13px 4px",
                    cursor: "pointer", fontFamily: "inherit",
                    display: "flex", flexDirection: "column", alignItems: "center", gap: 5,
                    transition: "all 0.15s",
                    transform: formCat === cat.id ? "scale(1.06)" : "scale(1)",
                    boxShadow: formCat === cat.id ? `0 4px 16px ${cat.c}28` : "none",
                  }}>
                    <span style={{ fontSize: 28 }}>{cat.e}</span>
                    <span style={{ fontSize: 10, fontWeight: 700, color: formCat === cat.id ? cat.c : "rgba(240,240,250,0.4)" }}>{cat.l}</span>
                  </button>
                ))}
              </div>
              <div style={{ display: "flex", gap: 10 }}>
                <button onClick={() => setStep(0)} style={{ flex: 1, padding: "15px", borderRadius: 16, background: CARD, border: `1px solid ${BORDER}`, color: MUTED, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit" }}>← Back</button>
                <button disabled={!canNext1} onClick={() => setStep(2)} style={{
                  flex: 2, padding: "15px", borderRadius: 16,
                  background: canNext1 ? "linear-gradient(135deg,#7c6bff,#9d4edd)" : "rgba(255,255,255,0.05)",
                  border: "none", color: canNext1 ? "#fff" : "rgba(240,240,250,0.2)",
                  fontSize: 16, fontWeight: 900, cursor: canNext1 ? "pointer" : "not-allowed",
                  fontFamily: "inherit", boxShadow: canNext1 ? "0 4px 20px rgba(124,107,255,0.32)" : "none",
                }}>Next →</button>
              </div>
            </div>
          )}

          {/* ── Step 2: Method + Note ── */}
          {step === 2 && (
            <div className="slide-up">
              <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 14 }}>how'd you pay?</div>
              <div style={{ display: "flex", gap: 10, marginBottom: 22 }}>
                {METHODS.map(m => (
                  <button key={m.id} onClick={() => setFormMethod(m.id)} style={{
                    flex: 1, background: formMethod === m.id ? "rgba(124,107,255,0.14)" : "rgba(255,255,255,0.03)",
                    border: formMethod === m.id ? `1.5px solid rgba(124,107,255,0.5)` : `1px solid ${BORDER}`,
                    borderRadius: 18, padding: "15px 6px",
                    cursor: "pointer", fontFamily: "inherit",
                    display: "flex", flexDirection: "column", alignItems: "center", gap: 6,
                    transition: "all 0.15s",
                    transform: formMethod === m.id ? "scale(1.05)" : "scale(1)",
                    boxShadow: formMethod === m.id ? "0 4px 18px rgba(124,107,255,0.22)" : "none",
                  }}>
                    <span style={{ fontSize: 30 }}>{m.e}</span>
                    <span style={{ fontSize: 13, fontWeight: 800, color: formMethod === m.id ? "#a78bfa" : MUTED }}>{m.l}</span>
                    <span style={{ fontSize: 10, color: "rgba(240,240,250,0.22)" }}>{m.desc}</span>
                  </button>
                ))}
              </div>

              <div style={{ marginBottom: 20 }}>
                <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 10 }}>note (optional)</div>
                <input
                  value={formNote} onChange={e => setFormNote(e.target.value)}
                  placeholder="what was this for? 👀"
                  style={{ width: "100%", background: "rgba(255,255,255,0.04)", border: `1px solid ${BORDER}`, borderRadius: 14, color: TEXT, fontSize: 15, padding: "13px 16px", outline: "none", fontFamily: "inherit", transition: "border 0.2s" }}
                  onFocus={e => e.target.style.border = `1px solid rgba(124,107,255,0.45)`}
                  onBlur={e => e.target.style.border = `1px solid ${BORDER}`}
                />
              </div>

              {/* Summary card */}
              <div style={{ background: "rgba(124,107,255,0.07)", border: "1px solid rgba(124,107,255,0.2)", borderRadius: 18, padding: "14px 16px", marginBottom: 22 }}>
                <div style={{ fontSize: 11, color: "rgba(167,139,250,0.6)", letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 10 }}>summary</div>
                <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
                  <span style={{ fontSize: 36 }}>{selCat?.e || "💸"}</span>
                  <div>
                    <div style={{ fontWeight: 900, fontSize: 22 }}>{fmt(parseFloat(formAmt) || 0)}</div>
                    <div style={{ fontSize: 13, color: MUTED, marginTop: 2 }}>
                      {selCat?.l || "—"} · via {selMth?.l || "—"}{formNote ? ` · "${formNote}"` : ""}
                    </div>
                  </div>
                </div>
              </div>

              <div style={{ display: "flex", gap: 10 }}>
                <button onClick={() => setStep(1)} style={{ flex: 1, padding: "15px", borderRadius: 16, background: CARD, border: `1px solid ${BORDER}`, color: MUTED, fontSize: 15, fontWeight: 700, cursor: "pointer", fontFamily: "inherit" }}>← Back</button>
                <button disabled={!canAdd} onClick={handleAddExpense} style={{
                  flex: 2.2, padding: "15px", borderRadius: 16,
                  background: canAdd ? "linear-gradient(135deg,#10b981,#059669)" : "rgba(255,255,255,0.05)",
                  border: "none", color: canAdd ? "#fff" : "rgba(240,240,250,0.2)",
                  fontSize: 16, fontWeight: 900, cursor: canAdd ? "pointer" : "not-allowed",
                  fontFamily: "inherit", boxShadow: canAdd ? "0 4px 20px rgba(16,185,129,0.3)" : "none",
                  transition: "all 0.2s",
                }}>✓ Log it</button>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  // ─── STATS SCREEN ──────────────────────────────────────────────────────────
  const curMonth = monthStr();
  const curYear = yearStr();
  const monthExps = expenses.filter(e => e.date.startsWith(curMonth));
  const monthTotal = monthExps.reduce((s, e) => s + e.amount, 0);
  const yearExps = expenses.filter(e => e.date.startsWith(curYear));
  const yearTotal = yearExps.reduce((s, e) => s + e.amount, 0);

  const activeExps = statsTab === "month" ? monthExps : yearExps;
  const activeTotal = statsTab === "month" ? monthTotal : yearTotal;

  const byCat = (exps) => CATS.map(cat => ({
    ...cat,
    total: exps.filter(e => e.cat === cat.id).reduce((s, e) => s + e.amount, 0),
    count: exps.filter(e => e.cat === cat.id).length,
  })).filter(c => c.total > 0).sort((a, b) => b.total - a.total);

  const catStats = byCat(activeExps);
  const catMax = catStats[0]?.total || 1;

  const yearMonths = Array.from({ length: 12 }, (_, i) => {
    const m = `${curYear}-${String(i + 1).padStart(2, "0")}`;
    const name = new Date(curYear, i).toLocaleString("default", { month: "short" });
    const total = expenses.filter(e => e.date.startsWith(m)).reduce((s, e) => s + e.amount, 0);
    return { name, total, m };
  });
  const yearMax = Math.max(...yearMonths.map(m => m.total), 1);

  const methodStats = METHODS.map(m => ({
    ...m,
    total: activeExps.filter(e => e.method === m.id).reduce((s, e) => s + e.amount, 0),
    count: activeExps.filter(e => e.method === m.id).length,
  })).filter(m => m.total > 0);

  const avgDaily = (() => {
    if (statsTab === "month") {
      const days = new Date().getDate();
      return monthTotal / days;
    }
    const dayOfYear = Math.ceil((new Date() - new Date(new Date().getFullYear(), 0, 0)) / 86400000);
    return yearTotal / dayOfYear;
  })();

  return (
    <div style={{ minHeight: "100vh", background: BG, fontFamily: "'Plus Jakarta Sans',sans-serif", color: TEXT, maxWidth: 430, margin: "0 auto" }}>
      <style>{CSS}</style>

      {/* Header */}
      <div style={{ padding: "52px 20px 14px", display: "flex", alignItems: "center", gap: 14, borderBottom: `1px solid ${BORDER}` }}>
        <button onClick={() => setScreen("home")} style={{ background: "rgba(255,255,255,0.05)", border: `1px solid ${BORDER}`, borderRadius: 12, width: 40, height: 40, cursor: "pointer", color: TEXT, fontSize: 20, display: "flex", alignItems: "center", justifyContent: "center" }}>
          ←
        </button>
        <div style={{ fontSize: 20, fontWeight: 900 }}>your stats 📊</div>
      </div>

      {/* Tabs */}
      <div style={{ padding: "14px 20px 0", display: "flex", gap: 8 }}>
        {[["month", "📅 This Month"], ["year", "🗓️ This Year"]].map(([t, label]) => (
          <button key={t} onClick={() => setStatsTab(t)} style={{
            padding: "9px 18px", borderRadius: 12, cursor: "pointer", fontFamily: "inherit", fontSize: 13, fontWeight: 800,
            background: statsTab === t ? ACCENT : CARD,
            border: statsTab === t ? "none" : `1px solid ${BORDER}`,
            color: statsTab === t ? "#fff" : MUTED,
            transition: "all 0.18s",
            boxShadow: statsTab === t ? "0 4px 16px rgba(124,107,255,0.28)" : "none",
          }}>{label}</button>
        ))}
      </div>

      <div style={{ padding: "16px 20px 60px", overflowY: "auto" }}>

        {/* Summary hero */}
        <div style={{ background: "linear-gradient(135deg,rgba(124,107,255,0.12),rgba(157,78,221,0.08))", border: "1px solid rgba(124,107,255,0.2)", borderRadius: 22, padding: "20px", marginBottom: 16 }}>
          <div style={{ fontSize: 11, color: "rgba(167,139,250,0.65)", letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 6 }}>
            {statsTab === "month"
              ? new Date().toLocaleString("default", { month: "long", year: "numeric" })
              : curYear + " total"}
          </div>
          <div style={{ fontSize: 40, fontWeight: 900 }}>{fmt(activeTotal)}</div>
          <div style={{ display: "flex", gap: 20, marginTop: 12 }}>
            <div>
              <div style={{ fontSize: 11, color: MUTED, fontWeight: 600 }}>transactions</div>
              <div style={{ fontSize: 18, fontWeight: 800 }}>{activeExps.length}</div>
            </div>
            <div>
              <div style={{ fontSize: 11, color: MUTED, fontWeight: 600 }}>avg / day</div>
              <div style={{ fontSize: 18, fontWeight: 800 }}>{fmt(avgDaily)}</div>
            </div>
            {statsTab === "month" && (
              <div>
                <div style={{ fontSize: 11, color: MUTED, fontWeight: 600 }}>vs limit/day</div>
                <div style={{ fontSize: 18, fontWeight: 800, color: avgDaily > limit ? "#ef4444" : "#10b981" }}>
                  {avgDaily > limit ? "over 🔴" : "under 🟢"}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Year: monthly chart */}
        {statsTab === "year" && (
          <>
            <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 12 }}>monthly breakdown</div>
            <div style={{ background: CARD, border: `1px solid ${BORDER}`, borderRadius: 20, padding: "18px 14px 14px", marginBottom: 16 }}>
              <div style={{ display: "flex", alignItems: "flex-end", gap: 5, height: 100 }}>
                {yearMonths.map(m => {
                  const h = Math.max((m.total / yearMax) * 88, m.total > 0 ? 5 : 0);
                  const isCur = m.m === curMonth;
                  return (
                    <div key={m.m} style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 5 }}>
                      <div style={{
                        width: "100%", height: `${h}px`,
                        background: isCur ? "linear-gradient(180deg,#7c6bff,#9d4edd)" : "rgba(255,255,255,0.09)",
                        borderRadius: "5px 5px 3px 3px",
                        transition: "height 0.5s ease",
                        boxShadow: isCur ? "0 2px 10px rgba(124,107,255,0.42)" : "none",
                      }} />
                      <span style={{ fontSize: 9, fontWeight: isCur ? 800 : 400, color: isCur ? "#a78bfa" : "rgba(240,240,250,0.3)" }}>{m.name}</span>
                    </div>
                  );
                })}
              </div>
            </div>
          </>
        )}

        {/* By category */}
        {catStats.length > 0 ? (
          <>
            <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 12 }}>by category</div>
            <div style={{ display: "flex", flexDirection: "column", gap: 10, marginBottom: 20 }}>
              {catStats.map(cat => (
                <div key={cat.id} style={{ background: CARD, border: `1px solid ${BORDER}`, borderRadius: 18, padding: "14px 16px" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 10 }}>
                    <div style={{ width: 40, height: 40, borderRadius: 12, background: `${cat.c}15`, border: `1px solid ${cat.c}28`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22, flexShrink: 0 }}>{cat.e}</div>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                        <span style={{ fontWeight: 700, fontSize: 15 }}>{cat.l}</span>
                        <span style={{ fontWeight: 900, fontSize: 16, color: cat.c }}>{fmt(cat.total)}</span>
                      </div>
                      <div style={{ fontSize: 11, color: "rgba(240,240,250,0.3)", marginTop: 2 }}>
                        {((cat.total / activeTotal) * 100).toFixed(0)}% of total · {cat.count} txn{cat.count !== 1 ? "s" : ""}
                      </div>
                    </div>
                  </div>
                  <div style={{ height: 5, background: "rgba(255,255,255,0.06)", borderRadius: 99 }}>
                    <div style={{ height: "100%", borderRadius: 99, width: `${(cat.total / catMax) * 100}%`, background: cat.c, transition: "width 0.7s cubic-bezier(0.34,1.56,0.64,1)", boxShadow: `0 0 8px ${cat.c}44` }} />
                  </div>
                </div>
              ))}
            </div>
          </>
        ) : (
          <div style={{ textAlign: "center", padding: "36px", color: "rgba(240,240,250,0.2)" }}>
            <div className="float" style={{ fontSize: 40, marginBottom: 10 }}>📭</div>
            <div>no data {statsTab === "month" ? "this month" : "this year"} yet</div>
          </div>
        )}

        {/* By payment method */}
        {methodStats.length > 0 && (
          <>
            <div style={{ fontSize: 11, color: MUTED, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, marginBottom: 12 }}>payment methods</div>
            <div style={{ display: "flex", gap: 10, marginBottom: 20 }}>
              {methodStats.map(m => (
                <div key={m.id} style={{ background: CARD, border: `1px solid ${BORDER}`, borderRadius: 18, padding: "16px 10px", flex: 1, textAlign: "center" }}>
                  <div style={{ fontSize: 28, marginBottom: 6 }}>{m.e}</div>
                  <div style={{ fontWeight: 900, fontSize: 14 }}>{fmt(m.total)}</div>
                  <div style={{ fontSize: 11, color: MUTED, fontWeight: 700, marginTop: 2 }}>{m.l}</div>
                  <div style={{ fontSize: 10, color: "rgba(240,240,250,0.22)", marginTop: 3 }}>{m.count}× used</div>
                </div>
              ))}
            </div>
          </>
        )}

        {/* Future scope callout */}
        <div style={{ background: "rgba(255,255,255,0.02)", border: "1px dashed rgba(255,255,255,0.1)", borderRadius: 16, padding: "14px 16px", display: "flex", gap: 12, alignItems: "flex-start" }}>
          <span style={{ fontSize: 20 }}>🔮</span>
          <div>
            <div style={{ fontSize: 13, fontWeight: 700, color: "rgba(240,240,250,0.5)", marginBottom: 3 }}>coming soon</div>
            <div style={{ fontSize: 12, color: "rgba(240,240,250,0.28)", lineHeight: 1.6 }}>Auto-detect UPI spends with confirmation · SMS parsing · Budget goals · Export CSV · Recurring expenses</div>
          </div>
        </div>
      </div>
    </div>
  );
}
