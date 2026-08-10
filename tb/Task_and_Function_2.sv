// Nakul Lakade
// Date: 06-08-2026
// Tasks and Functions


// ----------------calling task inside function----------------------------- 

class my_class;
  
  int data;
  static int static_data;
  
  static function void my_static_func();
    static_data = 10;
    $display("static data is %0d",static_data);
  endfunction
  
  function static void my_func_static();
    data =12;
    $display("my data= %0d",data);
  endfunction
  
  function int add(int a=10,int b=33);
    return a+b;
  endfunction
  
endclass


module task_functions_exp;
  
  int a,b,c;
 
  task my_addition();
    b=11;
    c=10;
    a= b+c;
    $display("sum= %0d", a);
  endtask
  
  function void my_add_func();
    my_addition();
  endfunction
  
  
  // class as return type and argument
  function my_class class_func(my_class m1);
    m1.data = m1.data + 20;
    return m1;
  endfunctionbb
  
  my_class m1,m2;
  
  initial begin
    m1= new();
    m2= class_func(m1);
    my_add_func();
    //   $display("addition= %0d",my_addition());
    //   $display("addition= %0d",my_addition(1,2));
    
    $display("my data[m1]= %0d, my data[m2]= %0d",m1.data,m2.data);
    
    my_class::my_static_func();
    m1.my_func_static();
    $display("addition value= %0d",m1.add(m1.add(11,22),m1.add(33,44)));
  end


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
endmodule
