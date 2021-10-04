#ifndef BINARYSEARCHTREE_BINARYTREE_H
#define BINARYSEARCHTREE_BINARYTREE_H

#include <stdio.h>
#include <stdlib.h>

// Referenced somewhat from: https://www.codesdope.com/blog/article/binary-search-tree-in-c/

/* 
    Currently only implemented a binary tree to store integers.
    Todo:
        1. Set better data type (most likely a struct defined in the symbol table)
        2. Add in a tree balancing algorithm (red/black)
        3. Convert search to return data instead of true/false
*/


struct TreeNode {
    int data; // Replace with better data type later
    struct TreeNode* left;
    struct TreeNode* right;
};

struct TreeNode* new_node(int x)
{
    struct TreeNode *p;
    p = malloc(sizeof(struct TreeNode));
    p->data = x;
    p->left = NULL;
    p->right = NULL;

    return p;
}

struct TreeNode* insert(struct TreeNode* root, int data) {
    if (root == NULL) {
        struct TreeNode* node;
        node = new_node(data);
        return node;
    }
    else if(data < root->data){
        root->left = insert(root->left, data);
    }
    else {
        root->right = insert(root->right, data);
    }
    return root;
}

// Find minimum of nodes
struct TreeNode* minVal(struct TreeNode* node) {
    struct TreeNode* current = node;
    while(current && current->left != NULL){
        current = current->left;
    }
    return current;
}

struct TreeNode* delete(struct TreeNode* root, int key) {
    if(root == NULL) {
        return root;
    }
    else if(key < root->data) { // Navigate left
        root->left = delete(root->left, key);
    }
    else if(key > root->data) { // Navigate right
        root->right = delete(root->right, key);
    }
    else { // Delete nodes once found
        if (root->left==NULL && root->right==NULL) { // No Children
            free(root);
            return NULL;
        }
        else if (root->left==NULL || root->right==NULL) { // One Child
            struct TreeNode* temp;
            if(root->left==NULL) {
                temp = root->right;
            }
            else {
                temp = root->left;
            }
            free(root);
            return temp;
        }
        else { // Two Children
            struct TreeNode* temp = minVal(root->right);
            root->data = temp->data;
            root->right = delete(root->right, key);
        }
    }
}


// Will need to be modified to return the data requested based on our key name
int search(struct TreeNode* root, int target) {
    if(root == NULL) {
        return 0;
    }
    else if (target == root->data) {
        return 1;
    }
    else if (target < root->data) {
        return(search(root->left, target));
    }
    else {
        return(search(root->right, target));
    }
}

// Testing
void inorder(struct TreeNode *root)
{
    if(root!=NULL)
    {
        inorder(root->left);
        printf(" %d ", root->data);
        inorder(root->right)
    }
}

void display(struct TreeNode* temp) {
    if (temp == NULL) { return; }
    else {
        display(temp->left);
        printf("%i\n",temp->data );
        display(temp->right);
    }
}

// testing
// int main() {
//     printf("Program Start!\n");
//     struct TreeNode* root;
//     printf("Tree Node Declared!\n");
//     root = new_node(20);
//     printf("data assigned!");
//     printf("Inserting!\n");
//     insert(root,5);
//     insert(root,1);
//     insert(root,15);
//     insert(root,9);
//     insert(root,7);
//     insert(root,12);
//     insert(root,30);
//     insert(root,25);
//     insert(root,40);
//     insert(root, 45);
//     insert(root, 42);
//     printf("Print Tree!\n");
//     inorder(root);
//     printf("\n");
//     return 0;
// }

#endif //BINARYSEARCHTREE_BINARYTREE_H