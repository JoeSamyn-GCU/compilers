#include "AST.h"

#include <stdlib.h>
#include <stdio.h>
#include <iostream>

AST * New_Tree(std::string nt, struct AST* l, struct AST* r){

	// Allocate memory for struct
	struct AST* ast = (AST*)malloc(sizeof(struct AST));
	
	// Copy char array into nodetype property
	ast->nodeType = nt;

	// Assign left and right children
	ast->left = l;
	ast->right = r;

	return ast;

}

AST * New_Tree(std::string nt, struct AST* l, struct AST* r, std::string reg, bool isNumber){

	// Allocate memory for struct
	struct AST* ast = (AST*)malloc(sizeof(struct AST));
	
	// Copy char array into nodetype property
	ast->nodeType = nt;

	// Assign left and right children
	ast->left = l;
	ast->right = r;
	ast->reg = reg;
	ast->isNumber = isNumber;
	return ast;

}

void insert_node_right(AST* parent, AST* node){
	if(parent == NULL){
		//printf("ERROR::Parent cannot be NULL");
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
		//printf("ERROR::Parent cannot be NULL");
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
	std::cout << node->nodeType << std::endl;

	// traverse left tree
	if(node->left != NULL){
		print_tree(node->left, level+1);
	}

	
}