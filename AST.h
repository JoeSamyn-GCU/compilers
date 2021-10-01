//Abstract Syntax Tree Implementation
#include <string.h>
/**
 * Node Class used to hold AST Nodes
 */
struct AST{
	// Name of node or node type to be displayed when printing AST
	char nodeType[100];

	// Left child node
	struct AST * left;

	// Right Child Node
	struct AST * right;
};

/**
 * Create new AST node for the tree
 * 
 * @param nt (node type) name of node
 * @param l node to assign to left child
 * @param r node to assign to right child
 * @return new AST node pointer
 */
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

/**
 * Print spaces before node values to give tree appearance
 * 
 * @param level current level or depth of node being printed
 */
void print_spaces(int level){
	for(int i = 0; i < level; i++)
		printf("    ");
}

/**
 * Print the AST using ASCII characters and console through recursion
 * 
 * @param node current root
 * @param level starting depth or level
 */
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



























