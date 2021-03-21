private class Term {
	private Integer power;
	private Integer multiplier;
	private String action;
	private String value;
	
	// Parameterized Constructor 
	private Term(String action, Integer power, Integer multiplier) {
		this.action = action;
		this.power = power;
		this.multiplier = multiplier;
	}
	
	private Term() {
		
	}

	private Integer getPower() {
		return power;
	}
	private void setPower(Integer power) {
		this.power = power;
	}
	private Integer getMultiplier() {
		return multiplier;
	}
	private void setMultiplier(Integer multiplier) {
		this.multiplier = multiplier;
	}
	private String getAction() {
		return action;
	}
	private void setAction(String action) {
		this.action = action;
	}
}
