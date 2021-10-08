#include "AST.h"

#include <stdlib.h>
#include <stdio.h>

struct AST * New_Tree(char nt[100], struct AST* l, struct AST* r){

	// Allocate memory for struct
	struct AST* ast = malloc(sizeof(struct AST));
	
	// Copy char arra into nodetype property
	strcpy(ast->nodeType, nt);

	// Assign left and right children
	ast->left = l;
	ast->right = r;

	return ast;

}

void insert_node_right(AST* parent, AST* node){
	if(parent == NULL){
		printf("ERROR::Parent cannot be NULL");
		return;
	}

	AST* curr = parent;

	// search for next available left child
	while(curr->right != NULL){
		curr = curr->right;
	}

	curr->right = node;
}

void insert_node_left(AST* parent, AST* node){
	if(parent == NULL){
		printf("ERROR::Parent cannot be NULL");
		return;
	}

	AST* curr = parent;

	// search for next available left child
	while(curr->left != NULL){
		curr = curr->left;
	}

	curr->left = node;
}

void print_spaces(int level){
	for(int i = 0; i < level; i++)
		printf("    ");
}

void print_tree(struct AST* node, int level){

	if(node == NULL) return;

	// Traverse right first
	if(node->right != NULL){
		print_tree(node->right, level+1);
	}

	

	// print current node
	print_spaces(level);
	printf("%s\n", node->nodeType);

	// traverse left tree
	if(node->left != NULL){
		print_tree(node->left, level+1);
	}

	
}