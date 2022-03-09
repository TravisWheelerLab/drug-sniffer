package jlogp;

import Jama.Matrix;
import Jama.QRDecomposition;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * A datastructure useful for building a matrix for linear regression. You add
 * an example with teh add method which then takes the Map (Fingerprint) and
 * determines if there are any new keys present. If there are then it will add
 * the keys to the key Index and backfill the old data with zero. Then it will
 * add a new row to the table keeping the entries according to the key index.
 * This is then easily converted into a Matrix (JAMA type) or also there is a
 * solve method which will solve the linear regression problem with the supplied
 * right hand side and return the least squares solution for the regression.
 *
 * @author Jeffrey
 *
 */
public class FingerprintCountDataset
{

    private List<Integer> indexSet = null;
    private List<ArrayList<Double>> listOfLists = null;
    private int numMembers = 0;

    public FingerprintCountDataset()
    {
        indexSet = new ArrayList<>();
        listOfLists = new ArrayList<ArrayList<Double>>();
    }

    private void checkIndices(Map<Integer, Integer> fingerprint)
    {
        for (Integer index : fingerprint.keySet()) {
            if (!indexSet.contains(index)) {
                indexSet.add(index);
                zerofill();
            }
        }
    }

    /**
     * Will convert all 0 in the dataset to instead have the value of the
     * increment given This has the effect of resulting in a better solution to
     * the linear regression.
     *
     * @param increment
     */
    public void zerotosmallIncrement(double increment)
    {
        for (int i = 0; i < listOfLists.size(); i++) {
            for (int j = 0; j < listOfLists.get(i).size(); j++) {
                double element = listOfLists.get(i).get(j);
                if (element == 0) {
                    listOfLists.get(i).set(j, increment);
                }
            }
        }
    }

    /**
     * Will add the small increment to every position in the dataset, this has
     * the effect of resulting in a better solution to the linear regression.
     *
     * @param increment
     */
    public void addSmallIncrement(double increment)
    {
        for (int i = 0; i < listOfLists.size(); i++) {
            for (int j = 0; j < listOfLists.get(i).size(); j++) {
                double element = listOfLists.get(i).get(j) + increment;
                listOfLists.get(i).set(j, element);
            }
        }
    }

    /**
     * add in zeroes for use if a new index is added to the VectorCollection
     */
    private void zerofill()
    {
        for (ArrayList<Double> l : listOfLists) {
            l.add(0.0);
        }
    }

    /**
     * Add the fingerprint to the growing collection. It will check for new
     * index values and add them if necessary. If a new index is found then it
     * will also backfill the growing 2d structure with 0 where appropriate.
     *
     * @param fingerprint which extends IVector<Integer>
     */
    public void add(Map<Integer, Integer> fingerprint)
    {
        numMembers++;
        this.checkIndices(fingerprint);
        ArrayList<Double> toadd = new ArrayList<Double>();
        for (int index : indexSet) {
            if (fingerprint.get(index) != null) {
                toadd.add((double) fingerprint.get(index));
            }
            else {
                toadd.add(0.0);
            }
        }
        listOfLists.add(toadd);
    }

    /**
     *
     * @return the entire dataset as a double[][] for use in matrix maths
     */
    private double[][] calcArray()
    {
        int n = listOfLists.size();
        int m = indexSet.size();
        double[][] array = new double[n][m];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                array[i][j] = listOfLists.get(i).get(j);
            }
        }
        return array;
    }

    /**
     * turns the DataStructure into a 2d array for use in turning into a Matrix
     * (the jama.Matrix class takes 2d arrays)
     *
     * @return the 2d array as a double[][]
     */
    public double[][] getArray()
    {
        return calcArray();
    }

    /**
     * For a given index determines the number of times that fragment is
     * observed across the entire VectorCollection
     *
     * @param index to determine the occurance count
     * @return the count as an int
     */
    public int sumOccurrance(int index)
    {
        int count = 0;
        for (int i = 0; i < listOfLists.size(); i++) {
            count += listOfLists.get(i).get(index);
        }

        return count;
    }

    /**
     * Trims the VectorCollection to reduce the total number of indices to those
     * that only occur the given integer number of times.
     *
     * @param min the minimum support (comparison uses > and not >=)
     */
    public void trim(int min)
    {
        ArrayList<Integer> growingindex = new ArrayList<>();
        ArrayList<ArrayList<Double>> growingdata = new ArrayList<>();
        int entries = listOfLists.size();
        for (int j = 0; j < entries; j++) {
            growingdata.add(new ArrayList<Double>());
        }
        for (int i = 0; i < indexSet.size(); i++) {
            if (this.sumOccurrance(i) > min) {
                growingindex.add(indexSet.get(i));
                for (int j = 0; j < entries; j++) {
                    growingdata.get(j).add(listOfLists.get(j).get(i));
                }
            }
        }
        indexSet = growingindex;
        listOfLists = growingdata;
    }

    /**
     *
     * @return the JAMA matrix of the dataset
     */
    public Matrix getJamaMatrix()
    {
        return new Matrix(calcArray());
    }

    private double mean(double[] y)
    {
        long sum = 0;
        for (int i = 0; i < y.length; i++) {
            sum += y[i];
        }
        return (1.0 * sum) / y.length;
    }

    // additional methods for the solve
    public Map<Integer, Double> solve(Double[] rhs, int trim)
    {
        double[] conversion = new double[rhs.length];
        for (int i = 0; i < rhs.length; i++) {
            conversion[i] = ((double) rhs[i]);
        }

        return solve(conversion, trim);
    }

    public Map<Integer, Double> solve(List<Double> rhs, int trim)
    {
        int size = rhs.size();
        double[] conversion = new double[size];
        for (int i = 0; i < size; i++) {
            conversion[i] = (double) rhs.get(i);
        }

        return solve(conversion, trim);
    }

    /**
     * solves the matrix using QRDecomposition for the given right hand side
     * (rhs) at the given trim level
     *
     * @param rhs
     * @param trim
     * @return the Map of the solution
     */
    public Map<Integer, Double> solve(double[] rhs, int trim)
    {
        Map<Integer, Double> model = new HashMap<>();
        int N = rhs.length;
        trim(trim);
        Matrix lhs = getJamaMatrix();
        QRDecomposition solver = new QRDecomposition(lhs);
        Matrix Y = new Matrix(rhs, N);
        Matrix solution = solver.solve(Y);
        double sst = getSST(mean(rhs), rhs);
        Matrix residuals = lhs.times(solution).minus(Y);
        double sse = residuals.norm2() * residuals.norm2();
        double Rsquared = 1.0 - sse / sst;
        // System.out.println("Solved with R2 of "+Rsquared);
        for (int c = 0; c < solution.getRowDimension(); c++) {
            model.put(indexSet.get(c), solution.get(c, 0));
        }
        return model;
    }

    private double getSST(double mean, double[] rhs)
    {
        double sst = 0.0;
        for (int i = 0; i < rhs.length; i++) {
            double dev = rhs[i] - mean;
            sst += dev * dev;
        }
        return sst;
    }

    /**
     * gives the Indices as a List
     *
     * @return an ArrayList<Long> as a List<Long> containing the indices in the
     * same order as the dataset
     */
    public List<Integer> getIndices()
    {
        return indexSet;
    }

    /**
     *
     * @return the raw data as it is stored in the VectorCollection
     */
    public List<ArrayList<Double>> getFingerprintList()
    {
        return listOfLists;
    }

    /**
     *
     * @return the number of entries in the collection
     */
    public int entries()
    {
        return numMembers;
    }

    @Override
    public String toString()
    {
        return ("Contains " + indexSet.size() + " Indices for " + listOfLists.
                size() + " Datapoints");
    }

}
