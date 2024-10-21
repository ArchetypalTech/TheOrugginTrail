# Eli's Barn

the barn is old and smells of old hay and oddly dissolution

the floor is dirt and trampled dried horse shit scattered with straw and broken bottles

the smell is not unpleasent and reminds you faintly of petrol and old socks

```yaml
roomType: "barn"
```

## an old wooden barn door, leads south

```yaml
direction: South
type: "door"
material: "wood"
```

### actions:

#### [the door, closes with a creak](bensons-plain.md)

## a dusty window, at chest height

```yaml
direction: West
type: "window"
material: "glass"
```

### actions

#### [the window, now broken, falls open](elis-forge.md)

```yaml
enabled: false
```

#### the window, smashes, glass flies everywhere, very very satisfying

```yaml
type: "break"
affectsAction:
  actionID: TODO?
```
