#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <algorithm>
#include <filesystem>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>

using namespace std;
namespace fs = filesystem;

struct movie {
    int index;
    int start;
    int end;
    int category;
};

struct rbitset {
    int size = 24;
    int bs[24];

    __host__ __device__
    rbitset() {
        for (int i = 0; i < size; i++) {
            bs[i] = 0;
        }
    }

    __host__ __device__
    int get(int index) const {
        return bs[index];
    }

    __host__ __device__
    void set(int index) {
        bs[index] = 1;
    }
};

void writeOutput(string filename, int nMovies) {
    fs::path dir_path("outputs/");
    if (!fs::exists(dir_path)) {
        fs::create_directory(dir_path);
    }

    ofstream inputFile;
    filename = filename.replace(0, 5, "outputs/output-exaustiva-thrust");
    inputFile.open(filename);
    inputFile << nMovies << endl;

    inputFile.close();
}

struct orderByEndTime {
    __host__ __device__
    bool operator()(const movie& a, const movie& b) const {
        if (a.end != b.end) {
            return a.end < b.end;
        }
        return a.start < b.start;
    }
};

void printMovies(vector<movie> movies) {
    for (int i = 0; i < movies.size(); i++) {
        cout << movies[i].index << " " << movies[i].start << " " << movies[i].end << " " << movies[i].category + 1 << endl;
    }
}

struct populateBitset {
    __host__ __device__
    void operator()(int start, int end, rbitset& bitset) {
        if (start == 0) {
            for (int i = start; i < end; i++) {
                bitset.set(i);
            }
        } else {
            for (int i = start - 1; i < end; i++) {
                bitset.set(i);
            }
        }
    }
};

struct isWatchable {
    __host__ __device__
    bool operator()(int start, int end, const rbitset& bitset) const {
        if (start == end) {
            return false;
        }

        if (start > end) {
            return false;
        }

        for (int i = start; i < end; i++) {
            if (bitset.get(i)) {
                return false;
            }
        }

        return true;
    }
};

struct searchMoviesGpu {
    int numMovies;
    int numCat;
    movie* movies;
    int* categories;

    searchMoviesGpu(int _numMovies, int _numCat, movie* _movies, int* _categories) : 
        numMovies(_numMovies),
        numCat(_numCat),
        movies(_movies),
        categories(_categories) {}

    __host__ __device__
    int operator()(const int& combination) const {
        int nMovies = 0;
        rbitset bitset;
        int tempCategories[20];
        for (int i = 0; i < numCat; i++) {
            tempCategories[i] = *(categories+i);
        }

        // Max combinations without using pow() because it is super unefficient
        for (int i = 0; i < numMovies; i++) {
            if (combination & (1 << i)) {
                movie& movieRef = movies[i];
                if (tempCategories[movieRef.category] != 0 && isWatchable()(movieRef.start, movieRef.end, bitset)) {
                    populateBitset()(movieRef.start, movieRef.end, bitset);
                    nMovies++;
                    tempCategories[movieRef.category]--;
                }
            }
        }

        return nMovies;
    }
};

int main(int argc, char* argv[]) {
    int numMovies;
    int numCategories;

    string filename = argv[1];

    thrust::host_vector<int> categories;
    thrust::host_vector<movie> movies;

    cin >> numMovies >> numCategories;

    for (int i = 0; i < numCategories; i++) {
        int num;
        cin >> num;
        categories.push_back(num);
    }

    for (int i = 0; i < numMovies; i++) {
        int start, end, cat;
        cin >> start >> end >> cat;

        if (end == 0) {
            end = 24;
        }

        movie m = {i+1, start, end, cat-1};
        movies.push_back(m);
    }

    thrust::sort(thrust::host, movies.begin(), movies.end(), orderByEndTime());

    thrust::device_vector<int> combinations((1 << numMovies));
    thrust::sequence(combinations.begin(), combinations.end());

    thrust::device_vector<int> chosenMovies((1 << numMovies));
    thrust::device_vector<movie> movies_gpu(movies);
    thrust::device_vector<int> categories_gpu(categories);

    thrust::transform(
        combinations.begin(), 
        combinations.end(), 
        chosenMovies.begin(), 
        searchMoviesGpu(numMovies, numCategories, raw_pointer_cast(movies_gpu.data()), raw_pointer_cast(categories_gpu.data()))
    );

    thrust::host_vector<int> result = chosenMovies;

    int maxMovies = 0;
    for (long int i = 0; i < (1 << numMovies); i++) {
        if (result[i] > maxMovies) {
            maxMovies = result[i];
        }
    }

    writeOutput(filename, maxMovies);

    return maxMovies;
}
