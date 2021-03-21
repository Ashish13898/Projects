/*
 * Copyright (C) 1993-2020 ID Business Solutions Limited
 * All rights reserved
 */

import java.io.StringReader;
import java.util.*;
import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;

public class PolynomialSolver 
{
    public String getAnswer(String jsonString)
    {
    	ArrayList<Term> termList = new ArrayList<Term>();
    	if(!jsonString.contains(Constants.NUMERIC))
    	{
    		if(jsonString.contains(Constants.JSON))
    		{
    			jsonString = jsonString.replace(Constants.JSON,"");
    		}
    		JsonReader reader = Json.createReader(new StringReader(jsonString));
    		JsonObject jsonObject = reader.readObject();
    		reader.close();
    		
    		JSONParser p = new JSONParser();
    		
    		p.xValue = jsonObject.getInt(Constants.XVALUE);
    		JsonArray jArray = jsonObject.getJsonArray(Constants.TERMS);
    		
    		if (jArray != null) 
    		{ 
    			   for (int i=0;i<jArray.size();i++)
    			   { 
    				   JsonObject jsonObj = jArray.getJsonObject(i);
    				   termList.add(new Term(jsonObj.getString(Constants.ACTION),jsonObj.getInt(Constants.POWER),jsonObj.getInt(Constants.MULTIPLIER)));
    			   }
    			   p.terms = termList;
    		} 

        	return calculateValue(p);
    	}
    	else if(jsonString.contains(Constants.NUMERIC))
    		{
    			jsonString = jsonString.replace(Constants.NUMERIC,"");
    			return calculateValueFromEquation(jsonString);
    		}
    			
    	return null;
    }
    
    // Used for the Numeric part where the equation is given
    static String calculateValueFromEquation(String equation) 
    {
    	equation = equation.replaceAll("\\s+","");
    	String[] equList = equation.split(";");
    	
    	//Getting the values
    	String xVal = equList[0].split(Constants.EQUALS)[1];
    	String polyEqu = equList[1].split(Constants.EQUALS)[1];
    	
    	String[] polyList = polyEqu.split("");
    	JSONParser p = new JSONParser();
    	ArrayList<Term> termList = new ArrayList<Term>();
		Term term = new Term();
		
		p.xValue = Integer.valueOf(xVal);
		
		// Running a loop on the equation to create a JSONParser object 
		for(Integer i = 0; i<= polyList.length - 1; i++)
		{
			if(polyList[i].equals(Constants.PLUS) || polyList[i].equals(Constants.MINUS))
			{
				if(polyList[i].equals(Constants.MINUS))
				{
					term.action = Constants.SUBTRACT;
				}
				if(polyList[i].equals(Constants.PLUS))
				{
					term.action = Constants.ADD;
				}
			}
			else if(polyList[i].equals("x"))
			{
				ArrayList<String> multilierList = new ArrayList<String>();
				String multilierVal = "";
				//Running a loop to check if multiplier was more then 1 digit
				for(Integer j = i - 2; j>=0;j--)
				{
					if(!polyList[j].equals(Constants.MINUS) && !polyList[j].equals(Constants.PLUS))
					{
						multilierList.add(polyList[j]);
					}
					else break;
				}
				
				if(multilierList.size() > 1)
				{
					for(Integer z = multilierList.size() - 1; z>=0;z--)
					{
						multilierVal += multilierList.get(z);
					}
				}
				else
				{
					multilierVal = multilierList.size() == 1 ? multilierList.get(0) : Constants.ZERO; 
				}
				
				term.multiplier = Integer.valueOf(multilierVal);
			}
			else if(i - 1 <  polyList.length - 1 && polyList[i - 1].contains("^"))
			{
				term.power = Integer.valueOf(polyList[i]);
				termList.add(term);
				term = new Term();
			}
		}
		p.terms = termList;
    	return calculateValue(p);
    }
    
    // Used for the JSON part where the equation is given
    static String calculateValue(JSONParser jsonMap) 
    {
    	Integer xVal = jsonMap.xValue != null ? jsonMap.xValue : 0;
    	HashMap<String,String> resMap = new HashMap<String,String>();
    	String final_val = "";
    	
    	for(Term term : jsonMap.terms)
    	{
    		//multiplier has to be greater then zero
    		if(term.multiplier > 0) 
    		{
    			if(term.power > 0)
				{
    				String val;
    				val = Operations.powerXofY(String.valueOf(xVal),String.valueOf(term.power));
    				term.value = Operations.multiply(String.valueOf(term.multiplier),val);
    			}
    			else
    			{
    				term.value = String.valueOf(term.multiplier);
    			}
    			
    			if(!resMap.containsKey(term.action))
    			{
    				resMap.put(term.action, Constants.ZERO);
    			}
    			String resVal = resMap.get(term.action);
    			resMap.put(term.action, Operations.add(String.valueOf(resVal),String.valueOf(term.value)));
    		}
    	}
    	if(resMap.get(Constants.ADD) != null && resMap.get(Constants.SUBTRACT) != null)
    	{
    		final_val = Operations.subtract(resMap.get(Constants.ADD), resMap.get(Constants.SUBTRACT));	
    		
    		if(Operations.isSmaller(resMap.get(Constants.ADD), resMap.get(Constants.SUBTRACT)))
    		{
    			final_val = '-' + final_val;
    		}
    	}
    	else if(resMap.get(Constants.ADD) != null)
    	{
    		final_val = resMap.get(Constants.ADD);
    	}
    	else if(resMap.get(Constants.SUBTRACT) != null)
    	{    			
   			final_val = '-' + resMap.get(Constants.SUBTRACT);
    	}
		
    	if(final_val.startsWith(Constants.ZERO) || final_val.startsWith("-" + Constants.ZERO))
    	{
    		if(final_val.startsWith(Constants.ZERO)) 
    		{
       		 	return final_val.substring(1,final_val.length());
    		}
    		else if(final_val.startsWith("-" + Constants.ZERO))
    		{
    			return final_val.substring(0,1) + final_val.substring(2,final_val.length());
    		}
    			
    	}
		return final_val;
    }
}
