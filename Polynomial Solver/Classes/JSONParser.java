import java.util.ArrayList;
import java.util.List;

private class JSONParser {
	private Integer xValue;
	private List<Term> terms = new ArrayList<>();
	
	private Integer getxValue() {
		return xValue;
	}
	private void setxValue(Integer xValue) {
		this.xValue = xValue;
	}
	private List<Term> getTerms() {
		return terms;
	}
	private void setTerms(List<Term> terms) {
		this.terms = terms;
	}
	
}
