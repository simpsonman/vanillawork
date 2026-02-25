const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_KEY;

const supabase = createClient(url, key);

async function test() {
    const { data, error } = await supabase.rpc('create_company_with_owner', {
        p_name: "Test Co. " + Date.now(),
        p_timezone: "Asia/Seoul",
        p_business_registration_number: "999-99-99999"
    });

    console.log("RPC Data:", JSON.stringify(data, null, 2));
    console.log("RPC Error:", error);
}

test();
