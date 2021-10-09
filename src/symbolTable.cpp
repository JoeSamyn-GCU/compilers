Table() {
    this->parent = NULL;
}

Table(Table* parent) {
    this->parent = parent;
    parent->tables.push_back(this);
}

// entries methods
void insertEntry(Entry e) {
    entries.push_back(e);
    //printf("inserted");
}

void deleteEntry(char* name) {
    auto searchEntry = [](const Entry & temp) {
        return temp.name;
    };
    std::vector<struct Entry>::iterator it;
    it = std::find_if(entries.begin(), entries.end(), searchEntry);
    entries.erase(it);
}

struct Entry searchEntry(char* name) {
    for (int i = 0; i < entries.size(); i++) {
        if (entries.at(i).name == name) {
            return entries.at(i);
        }
    }
    
    Entry null; // Not great. It works for now
    return null;
}

void printEntries() {
    if (entries.size() == 0) {
        printf("No Entries\n");
    } 
    else {
        for (int i = 0; i < entries.size(); i++) {
            printf("%s\n",entries.at(i).name);
        }
    }
}