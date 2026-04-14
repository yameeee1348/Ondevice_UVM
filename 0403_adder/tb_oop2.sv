class weapon;

    string name;
    function new(string name);
        this.name = name;
        
    endfunction
    

    virtual function void shot();
        $display(" [%s]...no sound",name);
        
    endfunction

    
endclass //base_packet

class M16 extends weapon;

    function new(string name);
        super.new(name);
    endfunction
    
    virtual function void shot();
        $display(" [%s] 탕탕!",name);
    endfunction
endclass //

class K2 extends weapon;

    function new(string name);
        super.new(name);
    endfunction
    
    virtual function void shot();
        $display(" [%s] 빵빵!",name);
    endfunction
endclass //

class AUG extends weapon;
    
    function new(string name);
        super.new(name);
    endfunction

    virtual function void shot();
        $display(" [%s] 삐~~익~~텅텅",name);
    endfunction
endclass //



module tb_oop ();

    initial begin
        weapon blackpink= new("없음");
        weapon gun= new("주먹");
        M16 m16 = new("M16");
        AUG aug = new("AUG");
        K2 k2 = new("k2");


        

        $display("=== 다형성 데모 ===");
        blackpink.shot();
        $display("=== 무기 m16 변경 ===");
        blackpink=m16;
        blackpink.shot();
        $display("=== 무기 aug 변경 ===");
        blackpink=aug;
        blackpink.shot();
        $display("=== 무기 k2 변경 ===");
        blackpink=k2;   
        blackpink.shot();
    end
    
endmodule