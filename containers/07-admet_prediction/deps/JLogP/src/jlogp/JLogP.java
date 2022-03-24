package jlogp;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import static java.lang.String.format;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.LineIterator;
import org.openscience.cdk.exception.InvalidSmilesException;
import org.openscience.cdk.interfaces.IAtomContainer;
import org.openscience.cdk.qsar.DescriptorValue;
import org.openscience.cdk.qsar.result.DoubleResult;
import org.openscience.cdk.silent.SilentChemObjectBuilder;
import org.openscience.cdk.smiles.SmilesParser;

/**
 *
 * @author VISHWESH
 */
public class JLogP
{

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args)
    {
        if (args.length < 2)
        {
            System.err.println("Usage: java -jar JLogP.jar input.smi output.txt");
            System.exit(-1);
        }

        try
        {
            new JLogP().processFile(args[0], args[1]);
        }
        catch (Exception ex)
        {
            Logger.getLogger(JLogP.class.getName()).log(Level.SEVERE, null, ex);
            System.exit(-1);
        }
        System.exit(0);
    }

//------------------------------------------------------------------------------

    private void processFile(String filename, String outfilename) 
        throws FileNotFoundException, IOException, Exception
    {
        File file = new File(filename);
        LineIterator iterator = null;

        SmilesParser parser = new SmilesParser(SilentChemObjectBuilder.getInstance());
        int idx = 0;
        int failed = 0;
        
        FileWriter fw = null;

        try
        {
            fw = new FileWriter(new File(outfilename), true);
            
            iterator = FileUtils.lineIterator(file);
            String line, molname= "";
            String[] arr = null;
            while (iterator.hasNext())
            {
                line = iterator.nextLine().trim();
                //System.err.println("Processing " + line + " ...");
                idx += 1;
                arr = line.split("\\s+");
                if (arr.length > 1) {
                    molname = arr[1].trim();
                }
                IAtomContainer mol = null;
                
                try
                {
                    mol = parser.parseSmiles(arr[0]);
                }
                catch (InvalidSmilesException e)
                {
                    System.err.println("Failed " + line);
                    System.out.println(molname + "  NA");
                    fw.write(molname + " " + "NA" + System.getProperty("line.separator"));
                    fw.flush();
                    failed += 1;
                    continue;
                }
                JPlogPDescriptor desc = new JPlogPDescriptor();
                DescriptorValue answer = desc.calculate(mol);
                DoubleResult result = (DoubleResult) answer.getValue();
                if (Double.isNaN(result.doubleValue()))
                {
                    failed += 1;
                    fw.write(molname + " " + "NA" + System.getProperty("line.separator"));
                    //continue;
                }
                else
                {
                    //System.out.println(molname + " " + format("%.3f", result.doubleValue()));
                    fw.write(molname + " " + format("%.3f", result.doubleValue()) + System.getProperty("line.separator"));
                    fw.flush();
                }
		
            }

            System.err.println("Processed: " + idx + " molecules.");
            System.err.println("Failed: " + failed + " molecules.");
        }

        catch (FileNotFoundException ex)
        {
            throw ex;
        }
        catch (IOException ex)
        {
            throw ex;
        }
        finally
        {
            if (iterator != null)
                iterator.close();
            
            if (fw != null)
            {
                fw.close();
            }
        }
    }


//------------------------------------------------------------------------------
}
