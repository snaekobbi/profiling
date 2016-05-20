import java.io.File;
import java.util.List;
import javax.inject.Inject;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

import org.daisy.maven.xproc.api.XProcEngine;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackClassic;
import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.mavenBundlesWithDependencies;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;

import org.junit.Test;
import org.junit.runner.RunWith;

import org.ops4j.pax.exam.Configuration;
import static org.ops4j.pax.exam.CoreOptions.bootDelegationPackage;
import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.vmOption;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class run {
	
	@Test
	public void run() throws Exception {
		runDTBookToPEF();
	}
	
	private void runDTBookToPEF() {
		File baseDir = new File(PathUtils.getBaseDir());
		File source = new File(baseDir, "../resources/dtbook.xml");
		File outputDir = new File(baseDir, "target/tmp");
		engine.run("http://www.daisy.org/pipeline/modules/braille/dtbook-to-pef/dtbook-to-pef.xpl",
		           ImmutableMap.of("source", (List<String>)ImmutableList.of(source.toURI().toASCIIString())),
		           null,
		           ImmutableMap.of("pef-output-dir", outputDir.toURI().toASCIIString()),
		           null);
	}
	
	@Inject
	private XProcEngine engine;
	
	@Configuration
	public Option[] config() {
		File probeClasspath = new File(System.getProperty("user.home"),
		                               ".m2/repository/org/daisy/pipeline/yourkit-probes/${yourkit-probes.version}/"
		                               + "yourkit-probes-${yourkit-probes.version}.jar");
		return options(
			vmOption("-agentpath:${yourkit.home}/bin/mac/libyjpagent.jnilib="
			         + "dir=" + PathUtils.getBaseDir() + "/target/yourkit"
			         + ",onexit=memory"
			         + ",probeclasspath=" + probeClasspath
			         + ",probe=org.daisy.pipeline.yourkit.probes.Liblouis"
			         + ",probe=org.daisy.pipeline.yourkit.probes.XPath"
			         + ",probe=org.daisy.pipeline.yourkit.probes.XSLT"
			         + ",probe=org.daisy.pipeline.yourkit.probes.XProc"
			),
			vmOption("-Xbootclasspath/a:" + probeClasspath),
			bootDelegationPackage("org.daisy.pipeline.yourkit.probes"),
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/logback.xml"),
			systemProperty("org.daisy.pipeline.xproc.configuration").value(PathUtils.getBaseDir() + "/calabash.xml"),
			systemProperty("com.xmlcalabash.config.user").value(""),
			domTraversalPackage(),
			felixDeclarativeServices(),
			junitBundles(),
			mavenBundlesWithDependencies(
				brailleModule("dtbook-to-pef"),
				brailleModule("liblouis-utils"),
				brailleModule("liblouis-tables"),
				brailleModule("liblouis-native").forThisPlatform(),
				brailleModule("dotify-utils"),
				brailleModule("dotify-formatter"),
				mavenBundle("org.daisy.maven:xproc-engine-daisy-pipeline:?"),
				logbackClassic())
		);
	}
}
