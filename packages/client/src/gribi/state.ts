import { createSecretsState } from "@gribi/mud";

export type SecretState = {
    example: {
        secret: number
    }
}

export const privateState: () => SecretState = createSecretsState({
    example: {
        children: {
            secret: {
            }
        }
    }
});