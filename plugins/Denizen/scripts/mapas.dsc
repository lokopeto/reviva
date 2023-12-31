loadschem:
    type: world
    events:
        on server start:
            - schematic load name:lobby
            - schematic load name:florest

players:
    type: world
    debug: false
    events:
        on player join:
            - adjust <server.players> gamemode:ADVENTURE
        on player walks:
            - if <server.flag[expand].exists>:
                - foreach <server.flag[expand]>:
                    - teleport <[value]> <[value].location.with_y[<player.location.y>]>

killmobs:
    type: world
    events:
        on entity dies:
            - if !<server.players.contains[<context.entity>]>:
                - run expanspawn

comecar:
    type: command
    name: começar
    description: Does something
    usage: /começar
    permission: reviva.começar
    script:
        - heal player
        - feed player

        - teleport <server.players> <location[0.5,58,0.5,world]>
        - narrate "Recriando Mundo..." <server.players>

        - wait 10t

        - adjust <world[jogo]> destroy
        - ~createworld jogo generator:denizen:void

        - waituntil <world[jogo].exists>
        - gamerule <world[jogo]> doMobSpawning false

        - schematic paste name:LOBBY <location[-8,-64,-8,jogo]>
        - teleport <server.players> <location[0.5,65,0.5,jogo]>

        - flag server expandloc:<location[0.5,65,0.5]>
        - flag server expandlastloc:!
        - flag server expandlastloc:<location[0.5,65,0.5]>
        - flag server expandlast:!

        - run removexpan

        - waituntil <script[removexpan]>
        - flag server comecar

        - run expanspawn

        - teleport <server.players> <location[0.5,65,0.5,jogo]>
        - narrate "Mundo Criado..." <server.players>

expand:
    type: world
    events:
        on player right clicks armor_stand:
            - if <server.flag[expand]> contains <context.entity>:
                - foreach <server.flag[expand]>:
                    - flag server expandlastloc:->:<[value].location.backward[1].round_to[2].with_y[65].xyz>

                - if Sul|Norte|Leste|Oeste contains <context.entity.custom_name>:

                    - determine cancelled passively

                    - flag server expandloc:<context.entity.location.backward[9]>
                    - flag server expandlast:<context.entity.custom_name>

                    - random:
                        - repeat 1:
                            - schematic paste name:florest <context.entity.location.with_y[-64].backward[17].right[8]> angle:<context.entity.location.yaw>
                            - spawn cow <server.flag[expandloc]> save:uuidmob
                            - execute as_server "execute in minecraft:jogo run spreadplayers <server.flag[expandloc].x> <server.flag[expandloc].z> 0 7 true <entry[uuidmob].spawned_entity.uuid>"

                    - run removexpan

        on entity damaged by void:
            - adjust <context.entity> fall_distance:0
            - teleport <context.entity> <server.flag[expandloc]>
            - determine cancelled:true
            - playsound <context.entity> sound:BLOCK_NOTE_BLOCK_XYLOPHONE volume:0.8

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
        - flag server expand:!
        - if !<server.flag[expandlastloc].contains[<location[0,0,-8,0,0,jogo].add[<server.flag[expandloc]>]>]>:
            - spawn armor_stand[gravity=false;visible=false;equipment=air|air|air|redstone_block;custom_name=Norte;custom_name_visible=true] <location[0,0,-8,0,0,jogo].add[<server.flag[expandloc]>]> save:expandnorth
        - if !<server.flag[expandlastloc].contains[<location[0,0,8,0,180,jogo].add[<server.flag[expandloc]>]>]>:
            - spawn armor_stand[gravity=false;visible=false;equipment=air|air|air|redstone_block;custom_name=Sul;custom_name_visible=true] <location[0,0,8,0,180,jogo].add[<server.flag[expandloc]>]> save:expandsouth
        - if !<server.flag[expandlastloc].contains[<location[8,0,0,0,90,jogo].add[<server.flag[expandloc]>]>]>:
            - spawn armor_stand[gravity=false;visible=false;equipment=air|air|air|redstone_block;custom_name=Leste;custom_name_visible=true] <location[8,0,0,0,90,jogo].add[<server.flag[expandloc]>]> save:expandeast
        - if !<server.flag[expandlastloc].contains[<location[-8,0,0,0,-90,jogo].add[<server.flag[expandloc]>]>]>:
            - spawn armor_stand[gravity=false;visible=false;equipment=air|air|air|redstone_block;custom_name=Oeste;custom_name_visible=true] <location[-8,0,0,0,-90,jogo].add[<server.flag[expandloc]>]> save:expandwest

        - flag server expand:|:<entry[expandsouth].spawned_entity>|<entry[expandnorth].spawned_entity>|<entry[expandeast].spawned_entity>|<entry[expandwest].spawned_entity>

        - foreach <entry[expandsouth].spawned_entity>|<entry[expandnorth].spawned_entity>|<entry[expandeast].spawned_entity>|<entry[expandwest].spawned_entity> as:expandcompa:
            - if <list[<location[-8.5,65,0.5].xyz>|<location[9.5,65,0.5].xyz>|<location[0.5,65,-8.5].xyz>|<location[0.5,65,9.5].xyz>].contains_text[<[expandcompa].location.with_y[65].round_to[2].xyz>]>:
                - remove <[expandcompa]>