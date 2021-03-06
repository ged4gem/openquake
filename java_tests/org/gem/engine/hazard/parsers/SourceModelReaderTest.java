package org.gem.engine.hazard.parsers;

import static org.gem.engine.hazard.parsers.SourceModelTestHelper.areaSourceData;
import static org.gem.engine.hazard.parsers.SourceModelTestHelper.assertSourcesAreEqual;
import static org.gem.engine.hazard.parsers.SourceModelTestHelper.complexSourceData;
import static org.gem.engine.hazard.parsers.SourceModelTestHelper.pointSourceData;
import static org.gem.engine.hazard.parsers.SourceModelTestHelper.simpleFaultSourceData;
import static org.junit.Assert.assertEquals;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;
import org.opensha.sha.earthquake.rupForecastImpl.GEM1.SourceData.GEMSourceData;

public class SourceModelReaderTest {

    public static final String TEST_SOURCE_MODEL_FILE = "java_tests/data/source_model.xml";
    public static final double MFD_BIN_WIDTH = 0.1;

    /**
     * Compares source model as derived by reading nrML file with source model
     * defined by hand with the same data contained in the nrML file
     */
    @Test
    public void readsTheSourceModel() {
        List<GEMSourceData> srcList = new ArrayList<GEMSourceData>();
        srcList.add(simpleFaultSourceData());
        srcList.add(complexSourceData());
        srcList.add(areaSourceData());
        srcList.add(pointSourceData());

        SourceModelReader srcModelReader =
                new SourceModelReader(TEST_SOURCE_MODEL_FILE, MFD_BIN_WIDTH);

        List<GEMSourceData> srcListRead = srcModelReader.read();

        assertEquals(srcList.size(), srcListRead.size());
        assertSourcesAreEqual(srcListRead, srcList);
    }

    /**
     * This test was written to prevent a bug from being reintroduced.
     *
     * Previously, if the read() method was called multiple times, the source data
     * list would simply be appended. This would cause the reader to build a list
     * containing a bunch of duplicates.
     */
    @Test
    public void testSourceListResets() {
        SourceModelReader srcModelReader =
            new SourceModelReader(TEST_SOURCE_MODEL_FILE, MFD_BIN_WIDTH);

        assertEquals(4, srcModelReader.read().size());

        // previously, calling read again would duplicate the sources
        // read from the test file and double the list size
        srcModelReader.read();

        assertEquals(4, srcModelReader.read().size());
    }

}
