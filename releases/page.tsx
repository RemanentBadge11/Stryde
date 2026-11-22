import Link from "next/link";
export default function Home() {
  return (
    <main className="min-h-screen flex flex-col items-center">
                {/* Navbar - Full width for hard left alignment */}
      <nav className="w-full px-8 py-8 flex justify-between items-center">
        
        {/* Left side: Logo */}
        <div className="flex items-center gap-3">
          <img src="/logo.svg" alt="Logo" className="h-8 w-auto" />
          <span className="text-[#262626] font-light text-2xl">|</span>
          <img src="/STRYDE.svg" alt="Stryde" className="h-5 w-auto" />
        </div>
        
        {/* Right side: GitHub + Download */}
        <div className="flex items-center gap-4">
          <a 
            href="https://github.com/RemanentBadge11/Stryde" 
            target="_blank" 
            rel="noopener noreferrer"
            className="hover:opacity-80 transition"
          >
            <img src="/github.svg" alt="GitHub" className="h-8 w-auto" />
          </a>
          
          <a 
           href="https://github.com/RemanentBadge11/Stryde/releases/download/v0.1/Stryde-0.1.apk" 
            className="bg-white text-black px-6 py-2 rounded-full font-bold text-sm hover:bg-gray-200 transition"
          >
            Download
          </a>
        </div>

      </nav>

      {/* Hero Section */}
      <section className="w-full max-w-4xl mx-auto px-6 pt-24 pb-16 text-center flex flex-col items-center">
        <div className="inline-block bg-surface border border-border px-4 py-1.5 rounded-full text-xs font-semibold tracking-wider text-textMuted mb-8">
          NOW AVAILABLE ON ANDROID
        </div>
        <h1 className="text-5xl md:text-7xl font-black tracking-tight mb-6 leading-tight">
          Level Up Your Fitness.
        </h1>
        <p className="text-textMuted text-lg md:text-xl max-w-2xl mb-12">
          The serious workout tracker with an RPG progression system. Track your lifts, complete quests, and rank up.
        </p>
        
        <a 
          href="https://github.com/RemanentBadge11/Stryde/releases/download/v0.1/Stryde-0.1.apk"
          className="bg-white text-black px-8 py-4 rounded-full font-bold text-lg hover:scale-105 transition transform duration-200 flex items-center gap-2"
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
          Download for Android
        </a>
        <p className="text-textMuted text-sm mt-4">Free download. No ads. No subscriptions.</p>
      </section>

      {/* Phone Mockup Placeholder */}
      <section className="w-full max-w-md mx-auto px-6 py-12 flex justify-center relative">
        <div className="absolute inset-0 bg-white/5 blur-[100px] rounded-full w-3/4 h-3/4 mx-auto top-1/4"></div>
        <div className="relative w-[300px] h-[600px] bg-surface border-[8px] border-[#222] rounded-[3rem] shadow-2xl overflow-hidden flex flex-col">
          {/* Fake Phone UI */}
          <div className="h-full w-full bg-black p-4 flex flex-col pt-12">
            <div className="text-2xl font-bold mb-6">Good morning.</div>
            <div className="bg-surface border border-border rounded-2xl p-5 mb-4">
               <div className="text-xs text-textMuted mb-1">LEVEL 1</div>
               <div className="text-xl font-bold mb-3">New Blood</div>
               <div className="w-full bg-border h-2 rounded-full overflow-hidden">
                 <div className="bg-white h-full w-1/5"></div>
               </div>
            </div>
            <div className="bg-surface border border-border rounded-2xl p-5">
               <div className="text-sm font-bold mb-3">Habits</div>
               <div className="flex justify-between items-center py-2 border-b border-border">
                  <div className="text-sm text-textMuted">Walk 10k steps</div>
                  <div className="text-xs bg-border px-2 py-1 rounded text-textMain">+30 XP</div>
               </div>
               <div className="flex justify-between items-center py-2">
                  <div className="text-sm text-textMuted">Drink 4L water</div>
                  <div className="text-xs bg-border px-2 py-1 rounded text-textMain">+25 XP</div>
               </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="w-full max-w-6xl mx-auto px-6 py-24">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          
          <div className="bg-surface border border-border p-8 rounded-3xl flex flex-col items-start">
            <div className="bg-black p-3 rounded-2xl mb-6 border border-border">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            </div>
            <h3 className="text-xl font-bold mb-3">RPG Progression</h3>
            <p className="text-textMuted text-sm leading-relaxed">Gain XP, level up, and assign skill points to your muscles. Turn your fitness journey into a game.</p>
          </div>

          <div className="bg-surface border border-border p-8 rounded-3xl flex flex-col items-start">
            <div className="bg-black p-3 rounded-2xl mb-6 border border-border">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6.5 6.5h11"/><path d="M6.5 17.5h11"/><path d="M3 10v4"/><path d="M21 10v4"/><path d="M6 7v10"/><path d="M18 7v10"/></svg>
            </div>
            <h3 className="text-xl font-bold mb-3">Serious Tracking</h3>
            <p className="text-textMuted text-sm leading-relaxed">Log sets, reps, and weight with a clean, distraction-free interface. Built for lifters who want to focus.</p>
          </div>

          <div className="bg-surface border border-border p-8 rounded-3xl flex flex-col items-start">
            <div className="bg-black p-3 rounded-2xl mb-6 border border-border">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <h3 className="text-xl font-bold mb-3">Quests & Habits</h3>
            <p className="text-textMuted text-sm leading-relaxed">Complete daily habits and weekly challenges to earn rewards. Stay consistent with gamified goals.</p>
          </div>

        </div>
      </section>

      {/* Footer */}
      <footer className="w-full border-t border-border py-12 text-center text-textMuted text-sm mt-auto">
        <p className="mb-4">© 2024 Stryde. All rights reserved.</p>
        <div className="flex justify-center gap-6">
          <Link href="/privacy" className="hover:text-white transition">Privacy Policy</Link>
          <a href="#" className="hover:text-white transition">Contact</a>
        </div>
      </footer>
    </main>
  );
}