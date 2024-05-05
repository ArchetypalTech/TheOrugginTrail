import * as THREE from "three";
import { AsciiEffect } from "three/examples/jsm/effects/AsciiEffect.js";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";

let scene: THREE.Scene;
let camera: THREE.PerspectiveCamera;
let sceneHolder: THREE.Object3D = new THREE.Object3D();
let controls: OrbitControls;
let currentSceneIndex = 0;
let sceneList: Map<string, THREE.Group<THREE.Object3DEventMap>> = new Map();

/**
 * Setup the Three.js scene and load the first scene.
 */
export function setupThree() {
	// Scene setup
	scene = new THREE.Scene();
	camera = new THREE.PerspectiveCamera(
		75,
		window.innerWidth / window.innerHeight,
		0.1,
		1000
	);
	loadScene(currentSceneIndex, true);
	let renderer = new THREE.WebGLRenderer();
	// Effect setup
	let effect = new AsciiEffect(renderer, " .·-:*=%@#", {
		invert: true,
	});
	effect.setSize(window.innerWidth, window.innerHeight);
	effect.domElement.style.color = "white";
	effect.domElement.style.backgroundColor = "black";
	// Controls setup
	controls = new OrbitControls(camera, effect.domElement);
	controls.enableZoom = false;
	controls.enablePan = false;
	controls.rotateSpeed = 1;
	effect.setSize(window.innerWidth, window.innerHeight);

	// This object holds the scenes that are loaded and is cleared when a new scene is loaded.
	scene.add(sceneHolder);

	// Lighting
	const light = new THREE.AmbientLight(0x404040); // soft white light
	scene.add(light);
	const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
	directionalLight.position.set(0, 1, 0);
	directionalLight.rotateX(Math.PI / 2);
	scene.add(directionalLight);

	// Handle Interactions like resizing the window or moving the camera.
	window.addEventListener("resize", () => {
		effect.setSize(window.innerWidth, window.innerHeight);
		camera.aspect = window.innerWidth / window.innerHeight;
		camera.updateProjectionMatrix();
	});

	function animate() {
		requestAnimationFrame(animate);
		effect.render(scene, camera);
	}
	animate();

	// Append the scene canvas to the viewport.
	const viewport = document.getElementById('viewport');
	if (viewport) {
		viewport.append(effect.domElement);
	}

	// Preload all scenes.
	//TODO If there are a bunch of scenes, this should probably be
	// done in a more optimized way depending on which scenes are likely to be
	// visited first based on the current position of the player.
	async function preloadScenes() {
		for (let i = 0; i < sceneData.length; i++) {
			const loader: GLTFLoader = new GLTFLoader();
			loader.load(
				sceneData[i].filename,
				function (gltf) {
					sceneList.set(sceneData[i].key, gltf.scene);
				},
				undefined,
				function (error) {
					console.error(error);
				}
			);
		}
	}
	preloadScenes();
}

function loadScene(index: number, firstRun: boolean = false) {
	const loader: GLTFLoader = new GLTFLoader();
	let loadedScene: THREE.Group<THREE.Object3DEventMap>;
	if (sceneList.has(sceneData[index].key)) {
		loadedScene = sceneList.get(sceneData[index].key);
		finishLoading();
	} else {
		loader.load(
			sceneData[index].filename,
			function (gltf) {
				// make sure we're loading the active, not the first scene when the game starts.
				if (firstRun && index != currentSceneIndex) return;
				loadedScene = gltf.scene;
				sceneList.set(sceneData[index].key, loadedScene);
				finishLoading();
				currentSceneIndex = index;
			},
			undefined,
			function (error) {
				console.error(error);
			}
		);
	}
	// once the scene is loaded, update the sceneHolder and camera.
	function finishLoading() {
		sceneHolder.clear();
		sceneHolder.add(loadedScene);
		loadedScene.position.y = -0.5;
		// camera and controls.
		camera.position.x = sceneData[index].position.x;
		camera.position.y = sceneData[index].position.y;
		camera.position.z = sceneData[index].position.z;
		if (controls) {
			controls.target = new THREE.Vector3(
				camera.position.x,
				camera.position.y + 0.01,
				camera.position.z
			);
		}
		controls.update();
	}
}

/**
 * Update the scene based on the text received from the server.
 * @param text The text to compare to the sceneData keys.
 */
export function updateScene(text: string) {
	for (let i = 0; i < sceneData.length; i++) {
		if (text.startsWith(sceneData[i].key) && i != currentSceneIndex) {
			currentSceneIndex = i;
			loadScene(i);
		}
	}
}

const sceneData = [
	{
		filename: "/hill.gltf",
		position: { x: 20, y: 15, z: -10 },
		key: "You are standing on a high mountain pass\nit winds through the mountains, the path is treacherous\ntoilet papered trees cover the steep \nvalley sides below you.\nOn closer inspection the TP might \nbe the remains of a cricket team\nor perhaps a lost and very dead KKK picnic group.\nIt's brass monkeys.\n\nThere is a path made mainly from stone to the west.\nNo other players at this location",
	},
	{
		filename: "/plains.gltf",
		position: { x: 0, y: -0.5, z: 0 },
		key: "You are standing on a windswept plain\nthe wind blowing is cold and\nbison skulls in piles taller than houses\ncover the plains as far as your eye can see\nthe air tastes of burnt grease and bensons.\n\nYou can alse see a football\nA slightly deflated knock off uefa football,\nnot quite spherical, it's kickable though\n\nThere is a path made mainly from dirt to the north.\nand there is a path made mainly from mud to the east\nNo other players at this location",
	},
	{
		filename: "/room2.gltf",
		position: { x: 0, y: 0.7, z: 0 },
		key: "You are standing in a barn\nThe place is dusty and full of spiderwebs,\nsomething died in here, possibly your own self\nplenty of corners and dark shadows\n\nThere is a wood door to the south.\nand there is a wood window to the east\nBob, Steve and Nigel are here.",
	},
	// {
	// 	filename: "/hill.gltf",
	// 	position: { x: 20, y: 15, z: -10 },
	// 	key: "you open the  at the window\nthe door opens\n\n\nI love the sound of breaking glass\nespecially when I'm lonely, the panes and the frame shatter\nsatisfyingly spreading broken joy on the floor\n\nthe window, glass and frame smashed falls open\n",
	// },
	// {
	// 	filename: "/room.gltf",
	// 	position: { x: 0, y: 1.4, z: 0 },
	// 	key: "You are in \n\n",
	// },
];
