import { promisify } from 'util';
import mongoose from 'mongoose';
import CriminalModel from './schema/criminal';
import { countPages, collectURLs, getCriminalDetails } from './lib/scraper';
import { cleanEnv, url } from 'envalid';

const wait = promisify(setTimeout);

(async () => {
    const env = cleanEnv(process.env, { MONGO_CONNECTION_STRING: url() }, { strict: true, dotEnvPath: null });

    try {
        const connection = await mongoose.connect(env.MONGO_CONNECTION_STRING + '', {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            useFindAndModify: false,
            useCreateIndex: true,
        });

        const pages = await countPages();
        await wait(500);
        for (let i = 1; i <= pages; ++i) {
            const urls = await collectURLs(i);
            await wait(500);
            for (const url of urls) {
                const criminal = await getCriminalDetails(url);
                if (criminal) {
                    await CriminalModel.findOneAndUpdate({ url: criminal.url }, criminal, { upsert: true });
                }

                await wait(500);
            }
        }

        await connection.disconnect();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
})();
