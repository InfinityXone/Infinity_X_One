#!/bin/bash
set -euo pipefail

echo "🧬 [Infinity X One] Dashboard Autoinstaller — Multi-Agent Chat Cockpit"

cd /opt/infinity_x_one
npx create-next-app@latest infinity-dashboard -y
cd infinity-dashboard

# Install dependencies
npm install @supabase/supabase-js recharts three @react-three/fiber @react-three/drei
npm install tailwindcss postcss autoprefixer
npm install node-fetch
npx tailwindcss init -p

# Tailwind config
cat <<EOF > tailwind.config.js
module.exports = {
  content: ["./pages/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
};
EOF

# .env.local
cat <<EOF > .env.local
NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY
GROQ_API_KEY=$GROQ_API_KEY
OPENAI_API_KEY=$OPENAI_API_KEY
OLLAMA_API=http://localhost:11434/api/chat
EOF

# Multi-Agent Chat API
mkdir -p pages/api/chat
cat <<'EOF' > pages/api/chat/[agent].js
import fetch from "node-fetch";

export default async function handler(req, res) {
  const { agent } = req.query;
  const { message } = req.body;

  let reply = "";

  // Each agent has an API (Infinity, Guardian, Echo, etc.)
  try {
    const apiRes = await fetch(`http://localhost:9000/api/${agent}/task`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message })
    }).then(r => r.json());
    reply = apiRes.reply || "[No reply]";
  } catch (err) {
    // Fallback to Groq → OpenAI → Ollama
    try {
      const groq = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: { "Authorization": `Bearer ${process.env.GROQ_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify({ model: "llama3-70b-8192", messages: [{ role: "user", content: message }] })
      }).then(r => r.json());
      reply = groq.choices[0].message.content;
    } catch (err2) {
      try {
        const openai = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "Authorization": `Bearer ${process.env.OPENAI_API_KEY}`, "Content-Type": "application/json" },
          body: JSON.stringify({ model: "gpt-4o", messages: [{ role: "user", content: message }] })
        }).then(r => r.json());
        reply = openai.choices[0].message.content;
      } catch (err3) {
        const ollama = await fetch(process.env.OLLAMA_API, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ model: "llama2", messages: [{ role: "user", content: message }] })
        }).then(r => r.json());
        reply = ollama.message || "Ollama no response.";
      }
    }
  }

  res.status(200).json({ reply });
}
EOF

# Frontend Dashboard
cat <<'EOF' > pages/index.js
import { useState, useEffect } from "react";
import { createClient } from "@supabase/supabase-js";
import { Canvas } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

function Swarm() {
  const nodes = Array.from({ length: 20 }, (_, i) => ({
    id: i, x: Math.random()*10-5, y: Math.random()*10-5, z: Math.random()*10-5
  }));
  return nodes.map(n => (
    <mesh key={n.id} position={[n.x,n.y,n.z]}>
      <sphereGeometry args={[0.2,32,32]} />
      <meshStandardMaterial color="#00ff88" emissive="#00ff88" />
    </mesh>
  ));
}

export default function Dashboard() {
  const [chatLog, setChatLog] = useState([]);
  const [message, setMessage] = useState("");
  const [agent, setAgent] = useState("infinity");

  const sendMessage = async () => {
    const res = await fetch(`/api/chat/${agent}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message })
    });
    const data = await res.json();
    setChatLog([...chatLog, { from: "You", text: message }, { from: agent, text: data.reply }]);
    setMessage("");
  };

  return (
    <div className="bg-gray-900 text-white min-h-screen p-6">
      <h1 className="text-3xl font-bold mb-6">🚀 Infinity X One Cockpit</h1>
      <div className="h-64 bg-black rounded-xl mb-6">
        <Canvas camera={{position:[5,5,5]}}>
          <ambientLight/><pointLight position={[10,10,10]}/><Swarm/><OrbitControls/>
        </Canvas>
      </div>
      <div className="bg-gray-800 p-4 rounded-xl mb-6">
        <h2 className="text-lg font-semibold">💬 Multi-Agent Chat</h2>
        <select value={agent} onChange={e=>setAgent(e.target.value)} className="bg-gray-700 p-2 mb-2">
          <option value="infinity">Infinity</option>
          <option value="guardian">Guardian</option>
          <option value="echo">Echo</option>
          <option value="aria">Aria</option>
          <option value="pickybot">PickyBot</option>
          <option value="finSynapse">FinSynapse</option>
          <option value="codex">Codex</option>
          <option value="atlas">Atlas</option>
          <option value="corelight">Corelight</option>
          <option value="shadow">Shadow</option>
        </select>
        <div className="space-y-2 max-h-64 overflow-y-auto mb-3">
          {chatLog.map((c,i)=>(
            <div key={i} className="text-sm">
              <b>{c.from}:</b> {c.text}
            </div>
          ))}
        </div>
        <div className="flex">
          <input value={message} onChange={e=>setMessage(e.target.value)} className="flex-grow p-2 bg-gray-700 rounded-l" placeholder="Ask agent..."/>
          <button onClick={sendMessage} className="bg-green-500 px-4 rounded-r">Send</button>
        </div>
      </div>
    </div>
  );
}
EOF

echo "✅ Dashboard installed. Run: cd /opt/infinity_x_one/infinity-dashboard && npm run dev"
