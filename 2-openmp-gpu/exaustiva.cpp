#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <algorithm>
#include <filesystem>

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
    vector<int> bs = vector<int>(24, 0);

    int get(int index) {
        return bs[index];
    }

    void set(int index) {
        bs[index] = 1;
    }

    void print() {
        for (int i = 0; i < size; i++) {
            cout << bs[i];
        }

        cout << endl;
    }
};

void writeOutput(string filename, vector<movie> movies) {
    int numMovies = movies.size();

    int hoursWithoutMovies = 0;
    for (int i = 0; i < movies.size() - 1; i++) {
        hoursWithoutMovies += movies[i + 1].start - movies[i].end;
    }

    if (movies[numMovies - 1].end != 24) {
        hoursWithoutMovies += 24 - movies[numMovies - 1].end;
    }

    if (movies[0].start != 0) {
        hoursWithoutMovies += movies[0].start;
    }

    double screenPercentage = ((24 - hoursWithoutMovies) * 100) / 24.0;

    fs::path dir_path("outputs/");
    if (!fs::exists(dir_path)) {
        fs::create_directory(dir_path);
    }

    ofstream inputFile;
    filename = filename.replace(0, 5, "outputs/output-exaustiva");
    inputFile.open(filename);
    inputFile << numMovies << endl;
    inputFile << screenPercentage << endl;

    for (int i = 0; i < movies.size(); i++) {
        inputFile << movies[i].index << " " << movies[i].start << " " << movies[i].end << " " << movies[i].category << endl;
    }

    inputFile.close();
}

bool orderByEndTime(movie& a, movie& b) {
    if (a.end != b.end) {
        return a.end < b.end;
    }

    return a.start < b.start;
}

void printMovies(vector<movie> movies) {
    for (int i = 0; i < movies.size(); i++) {
        cout << movies[i].index << " " << movies[i].start << " " << movies[i].end << " " << movies[i].category + 1 << endl;
    }
}

void populateBiset(int start, int end, rbitset& bitset) {
    if (start == 0) {
        for (int i = start; i < end; i++) {
            bitset.set(i);
        }
    }
    else {
        for (int i = start - 1; i < end; i++) {
            bitset.set(i);
        }
    }
}

bool isWatchable(int start, int end, rbitset& bitset) {
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

vector<movie> searchMovies(vector<movie>& movies, vector<int>& categories) {
    vector<movie> bestSelection;
    int max = 0; 

    // Max combinations without using pow() because it is super unefficient
    int combinations = 1 << movies.size(); 

    for (int mask = 0; mask < combinations; mask++) {
        vector<movie> chosenMovies;
        rbitset bitset;
        vector<int> tempCategories = categories;

        for (int i = 0; i < movies.size(); i++) {
            if (mask & (1 << i)) {
                if (tempCategories[movies[i].category] != 0 && isWatchable(movies[i].start, movies[i].end, bitset)) {
                    populateBiset(movies[i].start, movies[i].end, bitset);
                    chosenMovies.push_back(movies[i]);
                    tempCategories[movies[i].category]--;
                }
            }
        }

        if (chosenMovies.size() > max) {
            max = chosenMovies.size();
            bestSelection = chosenMovies;
        }
    }

    return bestSelection;
}

int main(int argc, char* argv[]) {
    int numMovies;
    int numCategories;

    string filename = argv[1];

    vector<int> categories;
    vector<movie> movies;

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

    sort(movies.begin(), movies.end(), orderByEndTime);

    vector<movie> best = searchMovies(movies, categories);

    writeOutput(filename, best);

    return best.size();
}
