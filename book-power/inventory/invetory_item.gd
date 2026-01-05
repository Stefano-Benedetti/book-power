extends Resource

#script per modellare gli elementi dell'inventario
#negli altri oggetti per avere associati un oggetto che può andare nell'inventario
#bisognerà fare @export var nome_che_useremo_nello_script: InvItem

#definiamo la classe a cui apparterrà ogni oggetto dell'inventario
#ogni oggetto dell'inventario avrà un nome e una texture
class_name InvItem
@export var name: String = ""
@export var texture: Texture2D
