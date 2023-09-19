loadschem:
    type: world
    events:
        on server start:
            - schematic load name:lobby
            - schematic load name:florest

comecar:
    type: command
    name: começar
    description: Does something
    usage: /começar
    permission: reviva.começar
    script:
        - schematic paste name:LOBBY <location[-8,-64,-8,jogo]>
        - teleport <server.players> <location[0.5,65,0.5,jogo]>

        - flag server expandloc:<location[0.5,65,0.5]>
        - flag server expandlastloc:<location[0.5,65,0.5]>
        - flag server expandlast:!

        - run removexpan

        - wait 2t

        - run expanspawn

expandrotation:
    type: world
    events:
        on player right clicks armor_stand:
            - if <server.flag[expand]> contains <context.entity>:
                - if Sul|Norte|Leste|Oeste contains <context.entity.custom_name>:

                    - determine cancelled passively

                    - flag server expandloc:<context.entity.location.backward[9]>
                    - flag server expandlastloc:<context.entity.location.backward[1]>
                    - flag server expandlast:<context.entity.custom_name>

                    - schematic paste name:florest <context.entity.location.backward[17].below[129].right[8]> angle:<context.entity.location.yaw>

                    - run removexpan
        on player damaged by void:
            - adjust <player> fall_distance:0
            - teleport <player> <location[0.5,65,0.5,jogo]>
            - determine cancelled:true







removexpan:
    type: task
    script:

        - foreach <server.flag[expand]> as:expandenty:
            - remove <[expandenty]>

        - flag server expand:!

        - playsound <player> sound:BLOCK_NOTE_BLOCK_CHIME volume:0.8

expanspawn:
    type: task
    script:

        - spawn armor_stand[visible=false;equipment=air|air|air|redstone_block;custom_name=Sul;custom_name_visible=true] <location[0,0,8,0,180,jogo].add[<server.flag[expandloc]>]> save:expandsouth
        - spawn armor_stand[visible=false;equipment=air|air|air|redstone_block;custom_name=Norte;custom_name_visible=true] <location[0,0,-8,0,0,jogo].add[<server.flag[expandloc]>]> save:expandnorth
        - spawn armor_stand[visible=false;equipment=air|air|air|redstone_block;custom_name=Leste;custom_name_visible=true] <location[8,0,0,0,90,jogo].add[<server.flag[expandloc]>]> save:expandeast
        - spawn armor_stand[visible=false;equipment=air|air|air|redstone_block;custom_name=Oeste;custom_name_visible=true] <location[-8,0,0,0,-90,jogo].add[<server.flag[expandloc]>]> save:expandwest

        - modifyblock <entry[expandsouth].spawned_entity.location.to_cuboid[location[<entry[expandsouth].spawned_entity.location.x>,<entry[expandsouth].spawned_entity.location.y.add[1]>,<entry[expandsouth].spawned_entity.location.z>]]>

        - flag server expand:|:<entry[expandsouth].spawned_entity>|<entry[expandnorth].spawned_entity>|<entry[expandeast].spawned_entity>|<entry[expandwest].spawned_entity>

        - wait 1t

        - foreach <entry[expandsouth].spawned_entity>|<entry[expandnorth].spawned_entity>|<entry[expandeast].spawned_entity>|<entry[expandwest].spawned_entity> as:expandcompa:
            - if <server.flag[expandlastloc].block> = <[expandcompa].location.block>:
                - remove <[expandcompa]>