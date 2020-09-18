import RightShifterTypes::*;
import Gates::*;
import FIFO::*;

// ��һ��Lab1��return (sel == 0)?a:b;���������return (sel == 1)?a:b�ⲻ�ǿ��ˣ�
function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    return orGate(andGate(a, notGate(sel)),andGate(b, sel)); 
endfunction

function Bit#(32) multiplexer32(Bit#(1) sel, Bit#(32) a, Bit#(32) b);
	Bit#(32) res_vec = 0;
	for (Integer i = 0; i < 32; i = i+1)
	    begin
		res_vec[i] = multiplexer1(sel, a[i], b[i]);
	    end
	return res_vec; 
endfunction

function Bit#(n) multiplexerN(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
	Bit#(n) res_vec = 0;
	for (Integer i = 0; i < valueof(n); i = i+1)
	    begin
		res_vec[i] = multiplexer1(sel, a[i], b[i]);
	    end
	return res_vec; 
endfunction

// ��һ��Lab1��д�ĸ��ƺ���
function Bit#(n) copy_frontnum(Bit#(1) sign , Integer num);
  Bit#(n) result = 0;
  for(Integer i = 0;i < num;i = i+1)
    begin
      result[i] = sign;
    end
    return result;
endfunction

module mkRightShifterPipelined (RightShifterPipelined);
    FIFO#(Bit#(1)) high_num <- mkFIFO();
    FIFO#(Bit#(5)) shift_num <- mkFIFO();
    FIFO#(Bit#(32)) op_num <- mkFIFO();
    FIFO#(Bit#(38)) step_for_shift_1 <- mkFIFO();
    FIFO#(Bit#(38)) step_for_shift_2 <- mkFIFO();
    FIFO#(Bit#(38)) step_for_shift_4 <- mkFIFO();
    FIFO#(Bit#(38)) step_for_shift_8 <- mkFIFO();
    FIFO#(Bit#(38)) step_for_shift_16 <- mkFIFO();
    
    // ��������1λ�Ĺ�������ˮ���ܹ��ֶδ���5��λ�������
    rule step1 (True);
      Bit#(32) operand = op_num.first();
      Bit#(5) shamt = shift_num.first();
      Bit#(1) high_bit = high_num.first();
      
      let result = multiplexerN(shamt[0] , operand , {high_bit,operand[31:1]});
      // �洢��ˮ��step�Ľ��
      step_for_shift_1.enq({high_bit,shamt,result});
      high_num.deq();
      op_num.deq();
      shift_num.deq();
      
    endrule
    
    // ��������2λ�Ĺ���
    rule step2 (True);
      Bit#(32) result = step_for_shift_1.first()[31:0];
      Bit#(5) shamt = step_for_shift_1.first()[36:32];
      Bit#(1) high_bit = step_for_shift_1.first()[37];

      result = multiplexerN(shamt[1] , result , {copy_frontnum(high_bit,2),result[31:2]});
      
      step_for_shift_2.enq({high_bit,shamt,result});
      step_for_shift_1.deq();
    endrule
    
    // ��������4λ�Ĺ���
    rule step3 (True);
      Bit#(32) result = step_for_shift_2.first()[31:0];
      Bit#(5) shamt = step_for_shift_2.first()[36:32];
      Bit#(1) high_bit = step_for_shift_2.first()[37];

      result = multiplexerN(shamt[2] , result , {copy_frontnum(high_bit,4),result[31:4]});
      
      step_for_shift_4.enq({high_bit,shamt,result});
      step_for_shift_2.deq();
    endrule
    
    // ��������8λ�Ĺ���
    rule step4 (True);
      Bit#(32) result = step_for_shift_4.first()[31:0];
      Bit#(5) shamt = step_for_shift_4.first()[36:32];
      Bit#(1) high_bit = step_for_shift_4.first()[37];

      result = multiplexerN(shamt[3] , result , {copy_frontnum(high_bit,8),result[31:8]});
      
      step_for_shift_8.enq({high_bit,shamt,result});
      step_for_shift_4.deq();
    endrule
    
    // ��������16λ�Ĺ���
    rule step5 (True);
      Bit#(32) result = step_for_shift_8.first()[31:0];
      Bit#(5) shamt = step_for_shift_8.first()[36:32];
      Bit#(1) high_bit = step_for_shift_8.first()[37];

      result = multiplexerN(shamt[4] , result , {copy_frontnum(high_bit,16),result[31:16]});
      
      step_for_shift_16.enq({high_bit,shamt,result});
      step_for_shift_8.deq();
    endrule
    
    
    method Action push(ShiftMode mode, Bit#(32) operand, Bit#(5) shamt);
  	/* Write your code here */
      // Action push�����������Ƶ�����������֡�����λ��
      Bit#(1) sign_bit = operand[31];
      Bit#(1) flag = 0;
      // ����Lab1��˼·���У��߼����Ʋ�0���������Ʋ�����λ
      if(mode == LogicalRightShift)
        begin
          flag = 1;
        end
      sign_bit = multiplexerN(flag , sign_bit , 0);
      
      // �Ѽ�����������ֺͲ��������
      high_num.enq(sign_bit);
      op_num.enq(operand);
      shift_num.enq(shamt);
    
    endmethod
	
    method ActionValue#(Bit#(32)) pull();
  	/* Write your code here */
      // ActionValue���ﷵ�����ƵĽ��
      Bit#(32) result = step_for_shift_16.first()[31:0];
      step_for_shift_16.deq();
      return result;
      endmethod

endmodule