import { useState,useEffect } from "react";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

export default function Cockpit(){
  const [msgs,setMsgs]=useState([]); const [input,setInput]=useState("");
  const [profit,setProfit]=useState(0); const [faucets,setFaucets]=useState([]); const [swarm,setSwarm]=useState(0);

  async function send(){ if(!input) return;
    setMsgs(m=>[...m,{role:"you",text:input}]);
    await fetch("/api/invoke/codex",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({command:input})});
    setMsgs(m=>[...m,{role:"codex",text:"Codex executing..."}]); setInput("");
  }

  useEffect(()=>{ 
    const t=setInterval(async()=>{
      let { data: p } = await supabase.from("profit_ledger").select("profit").order("created_at",{ascending:false}).limit(1);
      let { data: f } = await supabase.from("faucet_logs").select("message,created_at").order("created_at",{ascending:false}).limit(5);
      let { data: s } = await supabase.from("swarm_state").select("node_id").order("created_at",{ascending:false}).limit(1);
      if(p?.length) setProfit(p[0].profit); if(f?.length) setFaucets(f); if(s?.length) setSwarm(s.length);
    },5000);
    return()=>clearInterval(t);
  },[]);

  return(<div className="h-screen flex bg-black text-white">
    <aside className="w-72 bg-zinc-900 p-4">
      <h2 className="text-lg font-bold mb-4">∞X1 Agents</h2>
      {["PromptWriter","Codex","Guardian","PickyBot","Echo","Aria","FinSynapse","Infinity","Faucet"].map(a=>
        <div key={a}>🟢 {a}</div>)}
      <div className="mt-4 text-sm">Swarm: {swarm}</div>
      <div className="mt-2 text-sm">P&L: ${profit}</div>
    </aside>
    <main className="flex-1 flex flex-col">
      <header className="p-4 border-b border-zinc-800 flex justify-between">
        <span>∞X1 Cockpit</span><span>Agent Mode • Online</span>
      </header>
      <section className="flex-1 overflow-y-auto p-4 space-y-2">
        {msgs.map((m,i)=><div key={i} className={m.role==="you"?"text-blue-400":"text-green-400"}>{m.role}: {m.text}</div>)}
        <div className="mt-6"><h3 className="font-semibold">Recent Faucet Logs</h3>
          {faucets.map((f,i)=><div key={i} className="text-xs text-zinc-400">{f.created_at}: {f.message}</div>)}
        </div>
      </section>
      <footer className="p-4 flex gap-2">
        <input className="flex-1 bg-zinc-900 p-2" value={input} onChange={e=>setInput(e.target.value)} placeholder="Type directive..."/>
        <button onClick={send} className="bg-blue-600 px-4 py-2 rounded">Send</button>
      </footer>
    </main>
  </div>);
}
