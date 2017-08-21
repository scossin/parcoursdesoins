package parameters;

import javax.swing.plaf.synth.SynthSeparatorUI;

import ch.qos.logback.core.net.SyslogOutputStream;
import ontologie.EIG;

public class Test {
	
	public static void main (String[] args){
		System.out.println(Util.vf.createIRI(EIG.NAMESPACE,"p2").hashCode());
	}
}
