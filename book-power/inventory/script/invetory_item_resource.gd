extends Resource

#script per modellare gli la resource degli elementi dell'inventario
#negli altri oggetti per avere associati un oggetto che può andare
#nell'inventario bisognerà fare
#@export var nome_che_useremo_nello_script: InvItem

#definiamo la classe a cui apparterrà ogni ItemData dell'inventario
#ogni oggetto dell'inventario avrà un nome e una texture
class_name InvItem
@export var name: String = ""
@export var texture: Texture2D
@export var title: String = ""
@export var description: String = ""

func equals(item: InvItem):
	if item!=null :
		return name == item.name and description == item.description and title == item.title
