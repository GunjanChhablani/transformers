#!/usr/bin/bash

intermediate() {
    local seed=$1
    local ckpt=$2
    local step=$((ckpt/1000))

    local multiberts_ckpt_dir="multiberts-seed-${seed}-${step}k"
    # mkdir $multiberts_ckpt_dir
    # huggingface-cli repo create --yes ${multiberts_ckpt_dir} --organization google
    GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/google/${multiberts_ckpt_dir}
    
    # gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/bert.ckpt.data-00000-of-00001 ${multiberts_ckpt_dir}_orig/bert.ckpt.data-00000-of-00001
    # gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/bert.ckpt.index ${multiberts_ckpt_dir}_orig/bert.ckpt.index
    # gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/bert.ckpt.meta ${multiberts_ckpt_dir}_orig/bert.ckpt.meta
    # gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/checkpoint ${multiberts_ckpt_dir}_orig/checkpoint

    # python ../src/transformers/models/bert/convert_bert_original_tf_checkpoint_to_pytorch.py --tf_checkpoint_path ${multiberts_ckpt_dir}_orig/bert.ckpt --bert_config_file bert_config.json --pytorch_dump_path ${multiberts_ckpt_dir}/pytorch_model.bin
    
    # cp bert-base-uncased/tokenizer.json ${multiberts_ckpt_dir}
    # cp bert-base-uncased/tokenizer_config.json ${multiberts_ckpt_dir}
    # cp bert-base-uncased/vocab.txt ${multiberts_ckpt_dir}
    # cp config.json ${multiberts_ckpt_dir}
    cp README.md ${multiberts_ckpt_dir}

    cd ${multiberts_ckpt_dir}
    sed -i "s/seed-0/seed-${seed}/g" README.md
    sed -i "s/Seed 0/Seed ${seed}/g" README.md
    sed -i "s/Checkpoint 0/Checkpoint ${step}/g" README.md
    sed -i "s/checkpoint 0/checkpoint ${step}/g" README.md
    sed -i "s/-0k/-${step}k/g" README.md

    git add . && git commit -m "Update README"
    git push
    cd ..

    rm -rf ${multiberts_ckpt_dir}
    # rm -rf ${multiberts_ckpt_dir}_orig
}


final() {
    local seed=$1

    local multiberts_ckpt_dir="multiberts-seed-${seed}"

    git clone https://huggingface.co/google/${multiberts_ckpt_dir}

    # cp bert-base-uncased/tokenizer.json ${multiberts_ckpt_dir}
    # cp bert-base-uncased/tokenizer_config.json ${multiberts_ckpt_dir}
    # cp bert-base-uncased/vocab.txt ${multiberts_ckpt_dir}

    gsutil cp gs://multiberts/public/models/seed_${seed}/bert.ckpt.data-00000-of-00001 ${multiberts_ckpt_dir}_orig/bert.ckpt.data-00000-of-00001
    gsutil cp gs://multiberts/public/models/seed_${seed}/bert.ckpt.index ${multiberts_ckpt_dir}_orig/bert.ckpt.index
    gsutil cp gs://multiberts/public/models/seed_${seed}/bert.ckpt.meta ${multiberts_ckpt_dir}_orig/bert.ckpt.meta
    gsutil cp gs://multiberts/public/models/seed_${seed}/checkpoint ${multiberts_ckpt_dir}_orig/checkpoint

    python ../src/transformers/models/bert/convert_bert_original_tf_checkpoint_to_pytorch.py --tf_checkpoint_path ${multiberts_ckpt_dir}_orig/bert.ckpt --bert_config_file bert_config.json --pytorch_dump_path ${multiberts_ckpt_dir}/pytorch_model.bin

    cp final_ckpt/README.md ${multiberts_ckpt_dir}

    cd ${multiberts_ckpt_dir}
    # sed -i "s/seed-0/seed-${seed}/g" README.md
    # sed -i "s/Seed 0/Seed ${seed}/g" README.md
    git add . && git commit -m "Fix model file"
    git push
    cd ..

    rm -rf ${multiberts_ckpt_dir}
    rm -rf ${multiberts_ckpt_dir}_orig
}
# for seed in {0..4}; do
#     for ckpt in {0..200000..20000} ; do
#         intermediate ${seed} ${ckpt}
#     done
#     for ckpt in {200000..2000001..100000} ; do
#         intermediate ${seed} ${ckpt}
#     done
# done

# intermediate() {
#     local seed=$1
#     local ckpt=$2
#     local step=$((ckpt/1000))

#     local multiberts_ckpt_dir="multiberts-seed-${seed}-${step}k"
#     mkdir $multiberts_ckpt_dir
#     huggingface-cli repo create --yes ${multiberts_ckpt_dir} --organization google
#     git clone https://huggingface.co/google/${multiberts_ckpt_dir}
    
#     gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/bert.ckpt.data-00000-of-00001 ${multiberts_ckpt_dir}_orig/bert.ckpt.data-00000-of-00001
#     gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/bert.ckpt.index ${multiberts_ckpt_dir}_orig/bert.ckpt.index
#     gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/bert.ckpt.meta ${multiberts_ckpt_dir}_orig/bert.ckpt.meta
#     gsutil cp gs://multiberts/public/intermediates/seed_${seed}/step_${ckpt}/checkpoint ${multiberts_ckpt_dir}_orig/checkpoint

#     python ../src/transformers/models/bert/convert_bert_original_tf_checkpoint_to_pytorch.py --tf_checkpoint_path ${multiberts_ckpt_dir}_orig/bert.ckpt --bert_config_file bert_config.json --pytorch_dump_path ${multiberts_ckpt_dir}/pytorch_model.bin
    
#     cp README.md ${multiberts_ckpt_dir}
#     cp config.json ${multiberts_ckpt_dir}

#     cd ${multiberts_ckpt_dir}
#     sed -i "s/seed-0/seed-${seed}/g" README.md
#     sed -i "s/Seed 0/Seed ${seed}/g" README.md
#     sed -i "s/Checkpoint 0/Checkpoint ${step}/g" README.md
#     sed -i "s/checkpoint 0/checkpoint ${step}/g" README.md
#     sed -i "s/-0k/-${step}k/g" README.md

#     git add . && git commit -m "Add or Fix Model"
#     git push
#     cd ..

#     rm -rf ${multiberts_ckpt_dir}
#     rm -rf ${multiberts_ckpt_dir}_orig
# }

for seed in {0..24}; do
    final ${seed}
done

# for seed in {0..4}; do
#     for ckpt in {0..200000..20000} ; do
#         intermediate ${seed} ${ckpt}
#     done
#     for ckpt in {200000..2000001..100000} ; do
#         intermediate ${seed} ${ckpt}
#     done
# done

# seed=1
# ckpt=20000
# intermediate ${seed} ${ckpt}
