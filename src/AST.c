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