function [local_early_code,local_prompt_code,local_late_code,local_phase]=localcodeGenerate(local_early_code_last,code_nco_sum,code_table,settings)

    global earlyCodeNco;
    Ncoh = settings.Ncoh;
    code_temp = [];
    for n=1:Ncoh
        earlyCodeNco = earlyCodeNco + code_nco_sum;
        earlyCodeNco = mod(earlyCodeNco,2^32*1023);
        index = 1 + fix(earlyCodeNco/2^32);
        c = code_table(index);
        code_temp = [code_temp,c];
        if 1 == n 
            local_phase = earlyCodeNco/2^32*360;
        end
    end
    local_early_code = code_temp;
    local_prompt_code = [local_early_code_last(Ncoh-2:Ncoh),local_early_code(1:Ncoh-3)];
    local_late_code = [local_early_code_last(Ncoh-5:Ncoh),local_early_code(1:Ncoh-6)];