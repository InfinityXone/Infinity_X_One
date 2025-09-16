import fs from "fs";
import path from "path";
import { createClient } from "@supabase/supabase-js";
import { spawn } from "child_process";
import { harvestKeys } from "../../../API_KEY_HARVESTING_AGENT_SYSTEM";

const ENV_PATH = path.resolve("/opt/infinity_x_one/env/.env.prod");
const envVars = Object.fromEntries(
  fs.readFileSync(ENV_PATH, "utf-8").split("\\n")
    .filter((line) => line && !line.startsWith("#"))
    .map((line) => { const [k, ...r] = line.split("="); return [k, r.join("=")]; })
);
const supabase = createClient(envVars["SUPABASE_URL"]!, envVars["SUPABASE_SERVICE_ROLE_KEY"]!);
const KEY_VAULT_TABLE = envVars["KEY_VAULT_TABLE"] || "key_vault";

async function rotateKeys() {
  console.log("🔄 Starting key rotation…");
  try {
    const newKeys = await harvestKeys();
    console.log("✅ New keys harvested:", newKeys);
    for (const [service, key] of Object.entries(newKeys)) {
      await supabase.from(KEY_VAULT_TABLE).insert({ service, key, created_at: new Date().toISOString() });
    }
    let envContent = fs.readFileSync(ENV_PATH, "utf-8");
    for (const [service, key] of Object.entries(newKeys)) {
      const envKey = `${service.toUpperCase()}_KEY`;
      const regex = new RegExp(`^${envKey}=.*$`, "m");
      envContent = regex.test(envContent) ? envContent.replace(regex, `${envKey}=${key}`) : envContent + `\\n${envKey}=${key}`;
    }
    fs.writeFileSync(ENV_PATH, envContent, "utf-8");
    spawn("bash", ["-c", "source /opt/infinity_x_one/scripts/load_env.sh prod"], { stdio: "inherit", shell: true });
    console.log("🎉 Key rotation complete.");
  } catch (err) { console.error("❌ Rotation failed:", err); }
}
rotateKeys();
