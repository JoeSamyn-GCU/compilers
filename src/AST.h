#ifndef AST_H
#define AST_H
//Abstract Syntax Tree Implementation
#include <string>
#include <string.h>
/**
 * Node Class used to hold AST Nodes
 */
typedef struct AST{
	// Name of node or node type to be displayed when printing AST
	std::string nodeType;

	// Register the expression result is stored in
	std::string reg;

	bool isNumber;
	bool isIntVar;

	// Left child node
	struct AST * left;

	// Right Child Node
	struct AST * right;
} AST;

/**
 * Create new AST node for the tree
 *
 * @param nt (node type) name of node
 * @param l node to assign to left child
 * @param r node to assign to right child
 * @return new AST node pointer
 */
struct AST * New_Tree(std::string nt, struct AST* l, struct AST* r);

struct AST * New_Tree(std::string nt, struct AST* l, struct AST* r, std::string reg, bool isNumber=false);

/**
 * Insert node into the next available null right child of the parent subtree
 *
 * @param parent the starting node for the subtree
 * @param node the node to insert into the parent subtree
 * @return new tree with node added
 */
void insert_node_right(AST* parent, AST* node);

/**
 * Insert node into the next available null left child of the parent subtree
 *
 * @param parent the starting node for the subtree
 * @param node the node to insert into the parent subtree
 * @return new tree with node added
 */
void insert_node_left(AST* parent, AST* node);

/**
 * Print spaces before node values to give tree appearance
 *
 * @param level current level or depth of node being printed
 */
void print_spaces(int level);

/**
 * Print the AST using ASCII characters and console through recursion
 *
 * @param node current root
 * @param level starting depth or level
 */
void print_tree(struct AST* node, int level);
#endif
