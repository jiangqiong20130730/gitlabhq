# frozen_string_literal: true

require 'spec_helper'

describe RunPipelineScheduleWorker do
  describe '#perform' do
    set(:project) { create(:project) }
    set(:user) { create(:user) }
    set(:pipeline_schedule) { create(:ci_pipeline_schedule, :nightly, project: project ) }
    let(:worker) { described_class.new }

    context 'when a project not found' do
      it 'does not call the Service' do
        expect(Ci::CreatePipelineService).not_to receive(:new)
        expect(worker).not_to receive(:run_pipeline_schedule)

        worker.perform(100000, user.id)
      end
    end

    context 'when a user not found' do
      it 'does not call the Service' do
        expect(Ci::CreatePipelineService).not_to receive(:new)
        expect(worker).not_to receive(:run_pipeline_schedule)

        worker.perform(pipeline_schedule.id, 10000)
      end
    end

    context 'when everything is ok' do
      let(:create_pipeline_service) { instance_double(Ci::CreatePipelineService) }

      it 'calls the Service' do
        expect(Ci::CreatePipelineService).to receive(:new).with(project, user, ref: pipeline_schedule.ref).and_return(create_pipeline_service)
        expect(create_pipeline_service).to receive(:execute).with(:schedule, ignore_skip_ci: true, save_on_errors: false, schedule: pipeline_schedule)

        worker.perform(pipeline_schedule.id, user.id)
      end
    end
  end
end
