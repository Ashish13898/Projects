public class Operations 
{
	public static String add(String x,String y) 
    {
		 StringBuilder buf = new StringBuilder();
	        for ( int i1 = x.length() - 1, i2 = y.length() - 1, carry = 0;
	              i1 >= 0 || i2 >= 0 || carry != 0;
	              i1--, i2-- ) {
	            int digit1 = i1 < 0 ? 0 :
	                         Integer.parseInt(Character.toString(x.charAt(i1)));
	            int digit2 = i2 < 0 ? 0 :
	                         Integer.parseInt(Character.toString(y.charAt(i2)));
	            int digit = add(add(digit1 , digit2) , carry);
	            if (digit > 9) 
	            {
	                carry = 1;
	                digit = substract(digit,10);
	            }
	            else
	            {
	                carry = 0;
	            }
	            buf.append(digit);
	        }
	        return buf.reverse().toString();
    }
	
	public static String subtract(String x, String y) 
    {
        // Before proceeding further, make sure str1
        // is not smaller
        if (isSmaller(x, y)) {
            String t = x;
            x = y;
            y = t;
        }
 
        // Take an empty string for storing result
        String str = "";
 
        // Calculate length of both string
        int n1 = x.length(), n2 = y.length();
 
        // Reverse both of strings
        x = new StringBuilder(x).reverse().toString();
        y = new StringBuilder(y).reverse().toString();
 
        int carry = 0;
 
        // Run loop till small string length
        // and subtract digit of str1 to str2
        for (int i = 0; i < n2; i++) {
            // Do school mathematics, compute difference of
            // current digits
            int sub
                = ((int)(x.charAt(i) - '0')
                   - (int)(y.charAt(i) - '0') - carry);

            // If subtraction is less then zero
            // we add then we add 10 into sub and
            // take carry as 1 for calculating next step
            if (sub < 0) {
            	sub = add(sub, 10);
                carry = 1;
            }
            else
                carry = 0;
 
            str += (char)(sub + '0');
        }
 
        // subtract remaining digits of larger number
        for (int i = n2; i < n1; i++) {
            int sub = substract((int)(x.charAt(i) - '0'), carry);
 
            // if the sub value is -ve, then make it
            // positive
            if (sub < 0) {
                sub = add(sub, 10);
                carry = 1;
            }
            else
                carry = 0;
 
            str += (char)(sub + '0');
        }
 
        // reverse resultant string
        return new StringBuilder(str).reverse().toString();
    }
    static String powerXofY(String x, String y) {
    	if (y == Constants.ZERO) {
            return Constants.ONE;
        }
        if (x == Constants.ZERO) {
            return "";
        }
        if (y == Constants.ONE) {
            return String.valueOf(x);
        }
        String j = String.valueOf(x);
        Integer power = Integer.valueOf(y);
        while (power != 1)
        {
        	power = substract(power,1);;
            j = multiply(j,x);
        }
       return j;
	}
    
    static boolean isSmaller(String str1, String str2)
    {
        // Calculate lengths of both string
        int n1 = str1.length(), n2 = str2.length();
        if (n1 < n2)
            return true;
        if (n2 < n1)
            return false;
 
        for (int i = 0; i < n1; i++)
            if (str1.charAt(i) < str2.charAt(i))
                return true;
            else if (str1.charAt(i) > str2.charAt(i))
                return false;
 
        return false;
    }
    
    static int small_multiply(int x, int y) {
	    if (y != 0)
	        return (add(x , small_multiply(x, y - 1)));
	    else
	        return 0;
	} 
    
    public static int divideBy(int m, int n)
    {
        int c=0;
        while(m>=n)
        {
        	m = substract(m,n);
            ++c;
        }
        return c;
    }
    
    public static String multiply(String num1, String num2) 
    {  
     //Convert the string tocharArray
     char chars1[] = num1.toCharArray();
     char chars2[] = num2.toCharArray();

     //Declare a container to store the result and two products

     int result[] = new int[chars1.length + chars2.length];
     int n1[]= new int[chars1.length];
     int n2[]= new int[chars2.length];

     //PutcharConvert tointArray.

     for (int i =0; i < chars1.length; i++)
     {
        n1[i] = chars1[i] - '0';
     }

     for (int j =0; j < chars2.length; j++)
     {
        n2[j] = chars2[j] - '0';
     }

     //Multiply one by one
     for (int i = 0; i < chars1.length; i++)
     {
        for (int j = 0; j < chars2.length; j++) {
          result[i+j] += small_multiply(n1[i],  n2[j]);
        }
     }

     //Full decimal from back to front
     for (int i = result.length -1; i > 0; i--) 
     {
        result[i-1] += divideBy(result[i], 10);
        String val = Integer.toString(result[i]);
        result[i] = Integer.valueOf(val.split("")[val.length() - 1]);
     }
     
     //transformstringAnd return
     String resultStr = "";
     for (int i = 0; i < result.length - 1; i++) 
     {
        resultStr += "" +result[i];
     }
     return resultStr;
   }
}
