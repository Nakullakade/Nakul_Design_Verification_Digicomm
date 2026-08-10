// Nakul Lakade
// Date: 07-08-2026
// Tasks and Functions - 2

module my_tasks_functions;
  
  // recursuve function factorial 
  function automatic int factorial(int a);
    if (a <= 0)
      return 1;
    else
      return a*factorial(a-1);
  endfunction
  
  task my_factorial_task;
    int a= 10;
    $display("factorial= %0d",factorial(a));
  endtask
  
  initial begin
    // my_factorial_task();
    int a= factorial(5);
    $display(a);
  end
  
//----------------------------------------------------------------------------------------
  
  // calling the same function in fork join 3 times 
  initial begin
    $display("before fork join none");
    fork 
      #2 $display("fact1= %0d",factorial(3));
      #5 $display("fact2= %0d",factorial(6));
      #4 $display("fact3= %0d",factorial(7));
    join_none
      #1 $display("after join none");
  end

//--------------------------------------------------------------------------------------- 
  
  // return dynamic arr, que, associative arr in function
  
  // queue
  typedef int my_queue[$];
  
  function automatic my_queue m_que(int a);
    my_queue q;
    
    for(int i=0; i<5; i++) begin
      q.push_back(i*a);
    end
    return q;
    
  endfunction
  
  
  // dynamic array
  typedef int dynamic[];
  
  function automatic dynamic m_dy(int a);
    dynamic dy;
    dy=new[10];
    for(int i=0; i<5; i++) begin
      dy[i]= i*a;
    end
    return dy;
    
  endfunction
  
  
  // associative array
  typedef int assoc[int];
  
  function automatic assoc m_as(int a);
    assoc m_as;
    for(int i=0; i<5; i++) begin
      m_as[i]= i*a;
    end
    return m_as;
    
  endfunction
  
  initial begin
    $display("my Queue= %0p",m_que(5));
    $display("my dynamic= %0p",m_dy(10));
    $display("my assoc= %0p",m_as(20));
  end
  
endmodule

//-----------------------------------------------------------------------------------------------

module fork_join_exp;
  
  bit clk;
  int a;
  
  initial $monitor("a= %0d",a);
    
  always @(posedge clk)
      begin
         a <= 1;
         a <= 3;
         a <= 4;
      end
  
  initial clk=0;
  
  always #5 clk= ~clk;
  
  initial #50 $finish;
  
endmodule

//----------------------------------------------------------------------------------------------------

class A;
   int data;
endclass

module m;
  
 function A my_class(A a1);
    return a1;
 endfunction

 A a1,a2;
  
 initial begin
    
    a1= new();
    a2 = my_class(a1);

    a2.data=10;
    a1.data=22;
  
    $display("a1= %0d, a2= %0d",a1.data,a2.data);
 end
  
endmodule
